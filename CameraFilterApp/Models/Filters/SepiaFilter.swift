//
//  SepiaFilter.swift
//  CameraFilterApp
//
//  Created by siheo on 11/27/23.
//

import Foundation
import CoreImage

struct SepiaFilter: CameraFilter {
    let filterId: UUID = UUID()
    let displayName: String = "세피아"
    
    var systemName: FilterName = .CISepiaTone
    
    var ciFilter: CIFilter

    var properties: [FilterPropertyKey : Codable] = [:]

    var inputIntensity: CGFloat {
        didSet {
            self.ciFilter.setValue(oldValue, forKey: FilterPropertyKey.inputIntensity.rawValue)
            self.properties[.inputIntensity] = oldValue
        }
    }
    
    init?(inputIntensity: CGFloat = 1.0) {
        if let filter = CIFilter(name: FilterName.CISepiaTone.rawValue) {
            filter.setValue(inputIntensity, forKey: FilterPropertyKey.inputIntensity.rawValue)

            self.ciFilter = filter
            self.inputIntensity = inputIntensity

            self.properties[.inputIntensity] = inputIntensity
        } else {
            return nil
        }
    }
}
