//
//  MonochromeFilter.swift
//  CameraFilterApp
//
//  Created by siheo on 11/27/23.
//

import Foundation
import CoreImage

struct MonochromeFilter: CameraFilter {
    let filterId: UUID = UUID()
    var displayName: String
    
    var systemName: FilterName = .CIColorMonochrome

    var ciFilter: CIFilter

    var properties: [FilterPropertyKey : Codable] = [:]
    
    var inputColor: CIColor {
        didSet {
            self.ciFilter.setValue(self.inputColor, forKey: FilterPropertyKey.inputColor.rawValue)
            self.properties[.inputColor] = self.inputColor.stringRepresentation
        }
    }
    var inputIntensity: CGFloat = 1.0 {
        didSet {
            self.ciFilter.setValue(self.inputIntensity, forKey: FilterPropertyKey.inputIntensity.rawValue)
            self.properties[.inputIntensity] = self.inputIntensity
        }
    }

    init?(displayName: String, inputColor: CIColor, inputIntensity: CGFloat = 1.0) {
        if let filter = CIFilter(name: FilterName.CIColorMonochrome.rawValue) {
            filter.setValue(inputColor, forKey: "inputColor")
            filter.setValue(inputIntensity, forKey: "inputIntensity")
            
            self.ciFilter = filter
            self.displayName = displayName
            self.inputColor = inputColor
            self.inputIntensity = inputIntensity

            self.properties[.inputColor] = inputColor.stringRepresentation
            self.properties[.inputIntensity] = inputIntensity
        } else {
            return nil
        }
    }
}
