//
//  SepiaFilter.swift
//  CameraFilterApp
//
//  Created by siheo on 11/27/23.
//

import Foundation
import CoreImage

struct SepiaFilter: CameraFilter {
    let displayName: String = "세피아"
    
    var ciFilter: CIFilter?
    var inputIntensity: CGFloat {
        didSet {
            self.ciFilter!.setValue(oldValue, forKey: "inputIntensity")
        }
    }
    
    init(inputIntensity: CGFloat = 1.0) {
        self.inputIntensity = inputIntensity
        
        self.ciFilter = CIFilter(name: "CISepiaTone")!
        self.ciFilter!.setValue(self.inputIntensity, forKey: "inputIntensity")
    }
}
