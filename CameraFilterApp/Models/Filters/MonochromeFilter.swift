//
//  MonochromeFilter.swift
//  CameraFilterApp
//
//  Created by siheo on 11/27/23.
//

import Foundation
import CoreImage

class MonochromeFilter: CameraFilter {
    var displayName: String
    var inputColor: CIColor {
        didSet {
            self.ciFilter.setValue(oldValue, forKey: "inputColor")
        }
    }
    var inputIntensity: CGFloat = 1.0 {
        didSet {
            self.ciFilter.setValue(oldValue, forKey: "inputIntensity")
        }
    }
    
    var ciFilter: CIFilter
    
    init?(displayName: String, inputColor: CIColor, inputIntensity: CGFloat = 1.0) {
        if let filter = CIFilter(name: "CIColorMonochrome") {
            filter.setValue(inputColor, forKey: "inputColor")
            filter.setValue(inputIntensity, forKey: "inputIntensity")
            self.ciFilter = filter
            
            self.displayName = displayName
            self.inputColor = inputColor
            self.inputIntensity = inputIntensity
        } else {
            return nil
        }
    }
    
}
