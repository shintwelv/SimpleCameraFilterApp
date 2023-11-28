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
    var previewView: MTKView { get }
}

protocol CameraPreviewDataStore
{
    //var name: String { get set }
}

class CameraPreviewInteractor: NSObject, CameraPreviewBusinessLogic, CameraPreviewDataStore
{
    var presenter: CameraPreviewPresentationLogic?
    var worker: CameraPreviewWorker = CameraPreviewWorker()
    
    var previewView: MTKView = MTKView()
    
    private lazy var ciContext: CIContext = CIContext(mtlDevice: metalDevice)
    private var currentCIImage: CIImage?
    
    private let cameraQueue = DispatchQueue(label: "cameraQueue")
    private let videoQueue = DispatchQueue(label: "videoQueue")
    
    private let session = AVCaptureSession()
    
    private var deviceInput: AVCaptureDeviceInput!
    private var videoOutput: AVCaptureVideoDataOutput!
    
    var metalDevice: MTLDevice! = MTLCreateSystemDefaultDevice()
    
    lazy var metalCommandQueue: MTLCommandQueue! = metalDevice?.makeCommandQueue()
    
    private var appliedFilter: CIFilter?
    
    func startSession(_ request: CameraPreview.StartSession.Request) {
        self.configureCaptureSession()
        self.configureMetal()
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
    
    private func configureMetal() {
        self.previewView.device = self.metalDevice
        
        self.previewView.isPaused = true
        self.previewView.enableSetNeedsDisplay = false
        
        self.previewView.delegate = self
        
        self.previewView.framebufferOnly = false
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
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let ciImage = CIImage(cvImageBuffer: cvBuffer)
        
        if let _ = self.appliedFilter {
            guard let filteredImage = applyFilter(inputImage: ciImage) else {
                return
            }
            
            self.currentCIImage = filteredImage
            
        } else {
            self.currentCIImage = ciImage
        }
        
        self.previewView.draw()
    }
    
    func applyFilter(inputImage image: CIImage) -> CIImage? {
        var filteredImage: CIImage?
        
        self.appliedFilter?.setValue(image, forKey: kCIInputImageKey)
        filteredImage = self.appliedFilter?.outputImage
        
        return filteredImage
    }
}

extension CameraPreviewInteractor: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // do nothing
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer() else {
            return
        }
        
        guard let ciImage = self.currentCIImage else {
            return
        }
        
        guard let currentDrawable = view.currentDrawable else {
            return
        }
        
        let offset: (x:CGFloat, y:CGFloat) = (
            (view.drawableSize.width - ciImage.extent.width) / 2,
            (view.drawableSize.height - ciImage.extent.height) / 2
        )

        self.ciContext.render(ciImage,
                              to: currentDrawable.texture,
                              commandBuffer: commandBuffer,
                              bounds: CGRect(origin: CGPoint(x: -offset.x, y: -offset.y), size: view.drawableSize),
                              colorSpace: CGColorSpaceCreateDeviceRGB())
        
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
}
