//
//  VintageFilter.swift
//  CameraFilterApp
//
//  Created by siheo on 11/27/23.
//

import Foundation
import CoreImage

struct VintageFilter: CameraFilter {
    let displayName: String = "빈티지"
    
    var ciFilter: CIFilter
    
    init?() {
        if let filter = CIFilter(name: "CIPhotoEffectTransfer") {
            self.ciFilter = filter
        } else {
            return nil
        }
    }
}
