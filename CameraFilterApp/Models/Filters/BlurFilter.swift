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
    
    var ciFilter: CIFilter? = CIFilter(name: FilterName.CIBoxBlur.rawValue)!
    
    var properties: [FilterPropertyKey : Codable] = [:]
    
    var inputRadius: CGFloat = 10.0 {
        didSet {
            self.ciFilter?.setValue(self.inputRadius, forKey: FilterPropertyKey.inputRadius.rawValue)
            self.properties[.inputRadius] = self.inputRadius
        }
    }
    
    init(displayName: String, inputRadius: CGFloat = 10.0) {
        self.displayName = displayName
        self.inputRadius = inputRadius
        
        self.ciFilter?.setValue(inputRadius, forKey: FilterPropertyKey.inputRadius.rawValue)
        self.properties[.inputRadius] = inputRadius
    }
}
