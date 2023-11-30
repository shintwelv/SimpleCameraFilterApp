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

protocol CameraPreviewBusinessLogic
{
    func startSession(_ request: CameraPreview.StartSession.Request)
    func applyFilter(_ request: CameraPreview.ApplyFilter.Request)
    func fetchFilters(_ request: CameraPreview.FetchFilters.Request)
    var metalDevice: MTLDevice? { get }
}

protocol CameraPreviewDataStore
{
    //var name: String { get set }
}

class CameraPreviewInteractor: NSObject, CameraPreviewBusinessLogic, CameraPreviewDataStore
{
    var presenter: CameraPreviewPresentationLogic?
    var worker: CameraPreviewWorker = CameraPreviewWorker()
    
    
    private let cameraQueue = DispatchQueue(label: "cameraQueue")
    private let videoQueue = DispatchQueue(label: "videoQueue")
    
    private let session = AVCaptureSession()
    
    private var deviceInput: AVCaptureDeviceInput!
    private var videoOutput: AVCaptureVideoDataOutput!
    
    var metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()
    
    lazy var metalCommandQueue: MTLCommandQueue! = metalDevice?.makeCommandQueue()
    
    private var appliedFilter: CIFilter?
    
    func startSession(_ request: CameraPreview.StartSession.Request) {
        self.configureCaptureSession()
        cameraQueue.async {
            self.session.startRunning()
        }
    }
    
    func applyFilter(_ request: CameraPreview.ApplyFilter.Request) {
        let filterName = request.filterName
        
        let filter = worker.getFilter(by: filterName)
        
        self.appliedFilter = filter?.ciFilter ?? nil
    }
    
    func fetchFilters(_ request: CameraPreview.FetchFilters.Request) {
        let filters: [CameraFilter] = worker.allFilters
        let response = CameraPreview.FetchFilters.Response(filters: filters)
        presenter?.presentAllFilters(response: response)
    }
    
    private func configureCaptureSession() {
        let cameraDevice: AVCaptureDevice = worker.getCameraDevice()
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
    }
}

extension CameraPreviewInteractor: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
        let commandBuffer = metalCommandQueue.makeCommandBuffer() else {
            return
        }
        
        let ciImage = CIImage(cvImageBuffer: cvBuffer)
        if let _ = self.appliedFilter {
            guard let filteredImage = applyFilter(inputImage: ciImage) else {
                return
            }
            
            let response = CameraPreview.DrawFrameImage.Response(frameImage: filteredImage, commandBuffer: commandBuffer)
            
            presenter?.presentFrameImage(response: response)
        } else {
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
}
