//
//  MonochromeFilter.swift
//  CameraFilterApp
//
//  Created by siheo on 11/27/23.
//

import Foundation
import CoreImage

class MonochromeFilter: CameraFilter {
    let filterId: UUID = UUID()
    var displayName: String
    var inputColor: CIColor {
        didSet {
            self.ciFilter!.setValue(oldValue, forKey: "inputColor")
        }
    }
    var inputIntensity: CGFloat = 1.0 {
        didSet {
            self.ciFilter!.setValue(oldValue, forKey: "inputIntensity")
        }
    }
    
    var ciFilter: CIFilter? = CIFilter(name: "CIColorMonochrome")!
    
    init(displayName: String, inputColor: CIColor, inputIntensity: CGFloat = 1.0) {
        self.displayName = displayName
        self.inputColor = inputColor
        self.inputIntensity = inputIntensity
        
        self.ciFilter!.setValue(inputColor, forKey: "inputColor")
        self.ciFilter!.setValue(inputIntensity, forKey: "inputIntensity")
    }
    
}
