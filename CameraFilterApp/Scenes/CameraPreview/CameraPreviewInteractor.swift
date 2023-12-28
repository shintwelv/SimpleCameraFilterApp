//
//  CameraPreviewInteractor.swift
//  CameraFilterApp
//
//  Created by siheo on 11/27/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import MetalKit
import AVFoundation
import RxSwift

protocol CameraPreviewBusinessLogic
{
    func isSignedIn(_ request: CameraPreview.LoginStatus.Request)
    func signOut(_ request: CameraPreview.SignOut.Request)
    func startSession(_ request: CameraPreview.StartSession.Request)
    func pauseSession(_ request: CameraPreview.PauseSession.Request)
    func applyFilter(_ request: CameraPreview.ApplyFilter.Request)
    func fetchFilters(_ request: CameraPreview.FetchFilters.Request)
    func takePhoto(_ request: CameraPreview.TakePhoto.Request)
    func selectPhoto(_ request: CameraPreview.SelectPhoto.Request)
    var metalDevice: MTLDevice? { get }
}

protocol CameraPreviewDataStore
{
    var selectedPhoto: UIImage? { get set }
}

class CameraPreviewInteractor: NSObject, CameraPreviewBusinessLogic, CameraPreviewDataStore
{
    var presenter: CameraPreviewPresentationLogic?
    var worker: CameraPreviewWorker = CameraPreviewWorker()
    var filtersWorker: FiltersWorker = FiltersWorker(remoteStore: FilterFirebaseStore(), localStore: FilterMemStore())
    var authenticateProvider = UserAuthenticationWorker(provider: FirebaseAuthentication())
    
    private let cameraQueue = DispatchQueue(label: "cameraQueue")
    private let videoQueue = DispatchQueue(label: "videoQueue")
    private let imageProcessQueue = DispatchQueue(label: "imageProcessQueue")
    private let takePhotoQueue = DispatchQueue(label: "takePhotoQueue")
    
    private let session = AVCaptureSession()
    
    private var deviceInput: AVCaptureDeviceInput!
    private var videoOutput: AVCaptureVideoDataOutput!
    
    var metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()
    
    lazy var metalCommandQueue: MTLCommandQueue! = metalDevice?.makeCommandQueue()
    
    private var appliedFilter: CIFilter?
    
    private var takingPhoto: Bool = false

    var selectedPhoto: UIImage?
    
    func startSession(_ request: CameraPreview.StartSession.Request) {
        cameraQueue.async {
            self.session.startRunning()
        }
    }
    
    func takePhoto(_ request: CameraPreview.TakePhoto.Request) {
        takingPhoto = true
    }

    func pauseSession(_ request: CameraPreview.PauseSession.Request) {
        cameraQueue.async {
            self.session.stopRunning()
        }
    }
    
    override init() {
        super.init()
        
        configureCaptureSession()
        configureBinding()
    }
    
    private let bag = DisposeBag()
    
    private lazy var fetchedFilter: Observable<FiltersWorker.OperationResult<CameraFilter>> = {
        self.filtersWorker.filter.filter {
            switch $0 {
            case .Success(let operation, _) where operation == .fetch: return true
            case .Failure(let error) where error == .cannotFetch(error.localizedDescription): return true
            default: return false
            }
        }
    }()
    
    private func configureBinding() {
        self.fetchedFilter.map { (result) -> CameraFilter? in
            switch result {
            case .Success(_, let filter): return filter
            case .Failure(_): return nil
            }
        }.subscribe(
            onNext: { [weak self] filter in
                guard let self = self else { return }
                
                if let filter = filter {
                    self.appliedFilter = filter.ciFilter
                } else {
                    self.appliedFilter = nil
                }
            }
        ).disposed(by: self.bag)
        
        self.filtersWorker.filters.map { (result) -> [CameraFilter] in
            switch result {
            case .Success(let operation, let filters) where operation == .fetch: return filters
            default: return []
            }
        }.subscribe(
            onNext: { [weak self] filters in
                guard let self = self else { return }
                
                let response = CameraPreview.FetchFilters.Response(filters: filters)
                self.presenter?.presentAllFilters(response: response)
            }
        ).disposed(by: self.bag)
    }
    
    func isSignedIn(_ request: CameraPreview.LoginStatus.Request) {
        authenticateProvider.loggedInUser { [weak self] authResult in
            guard let self = self else { return }
            
            switch authResult {
            case .Success(let user):
                let userResult = CameraPreview.UserResult.Success(result: user)
                let response = CameraPreview.LoginStatus.Response(signedInUser: userResult)
                self.presenter?.presentLoginStatus(response: response)
            case .Failure(let error):
                let userResult = CameraPreview.UserResult<User?>.Failure(error: .cannotCheckLogin("\(error)"))
                let response = CameraPreview.LoginStatus.Response(signedInUser: userResult)
                self.presenter?.presentLoginStatus(response: response)
            }
        }
    }
    
    func signOut(_ request: CameraPreview.SignOut.Request) {
        authenticateProvider.logOut { [weak self] authResult in
            guard let self = self else { return }
            
            switch authResult {
            case .Success(let user):
                let userResult = CameraPreview.UserResult<User>.Success(result: user)
                let response = CameraPreview.SignOut.Response(signedOutUser: userResult)
                self.presenter?.presentSignedOutUser(response: response)
            case .Failure(let error):
                let userResult = CameraPreview.UserResult<User>.Failure(error: .cannotSignOut("\(error)"))
                let response = CameraPreview.SignOut.Response(signedOutUser: userResult)
                self.presenter?.presentSignedOutUser(response: response)
            }
        }
    }
    
    func applyFilter(_ request: CameraPreview.ApplyFilter.Request) {
        let filterId = request.filterId
        
        authenticateProvider.loggedInUser { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .Success(let user):
                self.filtersWorker.fetchFilter(user:user, filterId: filterId)
            case .Failure(let error):
                print(error)
                self.filtersWorker.fetchFilter(user:nil, filterId: filterId)
            }
        }
    }
    
    func fetchFilters(_ request: CameraPreview.FetchFilters.Request) {
        authenticateProvider.loggedInUser { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .Success(let user):
                self.filtersWorker.fetchFilters(user: user)
            case .Failure(let error):
                print(error)
                self.filtersWorker.fetchFilters(user: nil)
            }
        }
    }
    
    func selectPhoto(_ request: CameraPreview.SelectPhoto.Request) {
        let photo = request.photo
        self.selectedPhoto = photo
    }
    
    private func configureCaptureSession() {
        self.worker.cameraDevice.subscribe (
            onSuccess: { [weak self] cameraDevice in
                guard let self = self else { return }
                
                do {
                    self.deviceInput = try AVCaptureDeviceInput(device: cameraDevice)
                    
                    self.videoOutput = AVCaptureVideoDataOutput()
                    self.videoOutput.setSampleBufferDelegate(self, queue: self.videoQueue)
                    
                    self.session.addInput(self.deviceInput)
                    self.session.addOutput(self.videoOutput)
                    
                    self.videoOutput.connections.first?.videoOrientation = .portrait
                    
                    self.session.sessionPreset = .photo
                } catch {
                    print("error = \(error.localizedDescription)")
                }
                
            }, onFailure: { error in
                print(error.localizedDescription)
            }, onDisposed: {
                print("cameraDevice observable disposed")
            }
        ).disposed(by: self.bag)
    }
}

extension CameraPreviewInteractor: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
        let commandBuffer = metalCommandQueue.makeCommandBuffer() else {
            return
        }
        
        let copyBuffer = cvBuffer.copy()
        
        let ciImage = CIImage(cvImageBuffer: copyBuffer)
        if let _ = self.appliedFilter {
            guard let filteredImage = applyFilter(inputImage: ciImage) else { return }
            
            if self.takingPhoto {
                takePhotoQueue.async {
                    self.takingPhoto = false
                    
                    guard let uiImage = self.convert(filteredImage) else { return }
                    UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
            
            let response = CameraPreview.DrawFrameImage.Response(frameImage: filteredImage, commandBuffer: commandBuffer)
            
            presenter?.presentFrameImage(response: response)
        } else {
            if self.takingPhoto {
                takePhotoQueue.async {
                    self.takingPhoto = false
                    
                    guard let uiImage = self.convert(ciImage) else { return }
                    UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
            
            let response = CameraPreview.DrawFrameImage.Response(frameImage: ciImage, commandBuffer: commandBuffer)

            presenter?.presentFrameImage(response: response)
        }
    }
    
    func applyFilter(inputImage image: CIImage) -> CIImage? {
        var filteredImage: CIImage?
        
        self.appliedFilter?.setValue(image, forKey: kCIInputImageKey)
        filteredImage = self.appliedFilter?.outputImage
        
        return filteredImage
    }
    
    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Saving Photo Error: \(error.localizedDescription)")
        } else {
            let response = CameraPreview.TakePhoto.Response()
            self.presenter?.presentTakePhotoCompletion(response: response)
        }
    }
    
    private func convert(_ ciImage:CIImage) -> UIImage? {
        let context:CIContext = CIContext(options: nil)
        guard let cgImage:CGImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        let image:UIImage = UIImage(cgImage: cgImage)
        return image
    }
}
