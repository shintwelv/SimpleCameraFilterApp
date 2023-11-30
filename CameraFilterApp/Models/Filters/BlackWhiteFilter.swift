//
//  BlackWhiteFilter.swift
//  CameraFilterApp
//
//  Created by siheo on 11/27/23.
//

import Foundation
import CoreImage

struct BlackWhiteFilter: CameraFilter {
    var filterId: UUID = UUID()
    let displayName: String = "흑백"
    
    var systemName: FilterName = .CIPhotoEffectTonal
    
    var properties: [FilterPropertyKey : Codable] = [:]
    
    var ciFilter: CIFilter? = CIFilter(name: FilterName.CIPhotoEffectTonal.rawValue)!
}
