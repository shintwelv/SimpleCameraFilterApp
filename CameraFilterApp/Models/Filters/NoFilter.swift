//
//  NoFilter.swift
//  CameraFilterApp
//
//  Created by ShinIl Heo on 11/28/23.
//

import Foundation
import CoreImage

struct NoFilter: CameraFilter {
    var displayName: String = "기본"
    
    var ciFilter: CIFilter? = nil
}
