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
    
    var ciFilter: CIFilter
    var inputIntensity: CGFloat {
        didSet {
            self.ciFilter.setValue(oldValue, forKey: "inputIntensity")
        }
    }
    
    init?(inputIntensity: CGFloat = 1.0) {
        if let filter = CIFilter(name: "CISepiaTone") {
            filter.setValue(inputIntensity, forKey: "inputIntensity")
            self.ciFilter = filter

            self.inputIntensity = inputIntensity
        } else {
            return nil
        }
    }
}
