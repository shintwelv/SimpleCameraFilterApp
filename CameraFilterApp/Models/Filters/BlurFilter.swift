//
//  BlurFilter.swift
//  CameraFilterApp
//
//  Created by siheo on 11/30/23.
//

import Foundation
import CoreImage

struct BlurFilter: CameraFilter {
    var filterId: UUID = UUID()
    
    var displayName: String = "블러"
    
    var systemName: FilterName = .CIBoxBlur
    
    var ciFilter: CIFilter
    
    var properties: [FilterPropertyKey : Codable] = [:]
    
    var inputRadius: CGFloat = 10.0 {
        didSet {
            self.ciFilter.setValue(self.inputRadius, forKey: FilterPropertyKey.inputRadius.rawValue)
            self.properties[.inputRadius] = self.inputRadius
        }
    }
    
    init?(displayName: String, inputRadius: CGFloat = 10.0) {
        if let filter = CIFilter(name: FilterName.CIBoxBlur.rawValue) {
            filter.setValue(inputRadius, forKey: FilterPropertyKey.inputRadius.rawValue)
            self.ciFilter = filter

            self.displayName = displayName
            self.inputRadius = inputRadius
            
            self.properties[.inputRadius] = inputRadius
        } else {
            return nil
        }
    }
}
