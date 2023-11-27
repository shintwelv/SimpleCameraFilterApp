//
//  ViewController.swift
//  CameraFilterApp
//
//  Created by ShinIl Heo on 11/17/23.
//

import UIKit
import CoreImage
import AVFoundation
import MetalKit


class ViewController: UIViewController {
    
    private var mtkView: MTKView = MTKView()
    private var filterChangeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.filters"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        return button
    }()
    
    private var metalDevice: MTLDevice!
    private var metalCommandQueue: MTLCommandQueue!
    
    private var ciContext: CIContext!
    private var currentCIImage: CIImage?
    
    private let cameraQueue = DispatchQueue(label: "cameraQueue")
    private let videoQueue = DispatchQueue(label: "videoQueue")
    
    private let session = AVCaptureSession()
    
    private var deviceInput: AVCaptureDeviceInput!
    private var videoOutput: AVCaptureVideoDataOutput!
    
    private let sepiaFilter:CIFilter = {
        let filter = CIFilter(name: "CISepiaTone")!
        filter.setValue(NSNumber(value: 1), forKeyPath: "inputIntensity")
        return filter
    }()
    
    private var filterApplied: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureAutoLayout()
        
        configureMetal()
        configureCoreImage()

        configureCaptureSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        cameraQueue.async {
            self.session.startRunning()
        }
    }

    private func configureUI() {
        self.view.addSubview(self.mtkView)
        self.view.addSubview(self.filterChangeButton)
        
        self.filterChangeButton.addTarget(self, action: #selector(filterChangeButtonTapped), for: .touchUpInside)
    }
    
    private func configureAutoLayout() {
        self.mtkView.translatesAutoresizingMaskIntoConstraints = false
        self.filterChangeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.mtkView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.mtkView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.mtkView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.mtkView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.filterChangeButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            self.filterChangeButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -15),
            self.filterChangeButton.widthAnchor.constraint(equalToConstant: 40),
            self.filterChangeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func configureCaptureSession() {
        let cameraDevice: AVCaptureDevice = selectCamera()
        do {
            self.deviceInput = try AVCaptureDeviceInput(device: cameraDevice)
            
            self.videoOutput = AVCaptureVideoDataOutput()
            self.videoOutput.setSampleBufferDelegate(self, queue: self.videoQueue)
            
            self.session.addInput(self.deviceInput)
            self.session.addOutput(self.videoOutput)
            
            self.videoOutput.connections.first?.videoOrientation = .portrait
        } catch {
            print("error = \(error.localizedDescription)")
        }
    }
    
    private func selectCamera() -> AVCaptureDevice {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera,.builtInUltraWideCamera], mediaType: .video, position: .back)
        
        guard let cameraDevice = discoverySession.devices.first else {
            fatalError("no camera device is available")
        }
        
        return cameraDevice
    }
    
    private func configureMetal() {
        self.metalDevice = MTLCreateSystemDefaultDevice()
        
        self.mtkView.device = self.metalDevice
        
        self.mtkView.isPaused = true
        self.mtkView.enableSetNeedsDisplay = false
        
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        
        self.mtkView.delegate = self
        
        self.mtkView.framebufferOnly = false
    }
    
    private func configureCoreImage() {
        self.ciContext = CIContext(mtlDevice: self.metalDevice)
    }
    
    @objc private func filterChangeButtonTapped(_ button:UIButton) {
        filterApplied.toggle()
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let ciImage = CIImage(cvImageBuffer: cvBuffer)
        
        if self.filterApplied {
            guard let filteredImage = applyFilter(inputImage: ciImage) else {
                return
            }
            
            self.currentCIImage = filteredImage
            
        } else {
            self.currentCIImage = ciImage
        }
        
        self.mtkView.draw()
    }
    
    func applyFilter(inputImage image: CIImage) -> CIImage? {
        var filteredImage: CIImage?
        
        self.sepiaFilter.setValue(image, forKey: kCIInputImageKey)
        filteredImage = self.sepiaFilter.outputImage
        
        return filteredImage
    }
}

extension ViewController: MTKViewDelegate {
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
