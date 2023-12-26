//
//  VintageFilter.swift
//  CameraFilterApp
//
//  Created by siheo on 11/27/23.
//

import Foundation
import CoreImage

struct VintageFilter: CameraFilter {
    let filterId: UUID = UUID()
    let displayName: String = "빈티지"
    
    var systemName: FilterName = .CIPhotoEffectTransfer
    
    var properties: [FilterPropertyKey : Codable] = [:]
    
    var ciFilter: CIFilter
    
    init?() {
        if let filter = CIFilter(name: FilterName.CIPhotoEffectTransfer.rawValue) {
            self.ciFilter = filter
        } else {
            return nil
        }
    }
}
