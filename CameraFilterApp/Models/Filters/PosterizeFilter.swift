//
//  PosterizeFilter.swift
//  CameraFilterApp
//
//  Created by siheo on 11/30/23.
//

import Foundation
import CoreImage

struct PosterizeFilter: CameraFilter {
    var filterId: UUID = UUID()
    
    var displayName: String = "포스터"
    
    var systemName: FilterName = .CIColorPosterize
    
    var ciFilter: CIFilter? = CIFilter(name: FilterName.CIColorPosterize.rawValue)!
    
    var properties: [FilterPropertyKey : Codable] = [:]
    
    var inputLevel: CGFloat = 6.0 {
        didSet {
            self.properties[.inputLevels] = self.inputLevel
            self.ciFilter?.setValue(self.inputLevel, forKey: FilterPropertyKey.inputLevels.rawValue)
        }
    }
    
    init(displayName: String, inputLevels: CGFloat = 6.0) {
        self.displayName = displayName
        self.inputLevel = inputLevels
        
        self.properties[.inputLevels] = inputLevels
        self.ciFilter?.setValue(inputLevels, forKey: FilterPropertyKey.inputLevels.rawValue)
    }
}
