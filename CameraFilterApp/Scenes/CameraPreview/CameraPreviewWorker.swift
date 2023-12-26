//
//  CameraPreviewWorker.swift
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
import AVFoundation

class CameraPreviewWorker
{
    var allFilters: [CameraFilter] = {
        let filters: [CameraFilter?] = [
            SepiaFilter(inputIntensity: 1.0),
            VintageFilter(),
            BlackWhiteFilter(),
            MonochromeFilter(displayName: "시안", inputColor: CIColor.cyan),
            MonochromeFilter(displayName: "로즈", inputColor: CIColor.magenta),
            MonochromeFilter(displayName: "블루", inputColor: CIColor.blue),
            BlurFilter(displayName: "블러"),
            PosterizeFilter(displayName: "포스터")
        ]
        
        return filters.compactMap {$0}
    }()
    
    func getFilter(by name: String) -> CameraFilter? {
        return allFilters.filter { $0.displayName == name }.first
    }
    
    func getCameraDevice() -> AVCaptureDevice {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera,.builtInUltraWideCamera], mediaType: .video, position: .back)
        
        guard let cameraDevice = discoverySession.devices.first else {
            fatalError("no camera device is available")
        }
        
        return cameraDevice
    }
}
