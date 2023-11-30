//
//  NoFilter.swift
//  CameraFilterApp
//
//  Created by ShinIl Heo on 11/28/23.
//

import Foundation
import CoreImage

struct NoFilter: CameraFilter {
    let filterId: UUID = UUID()
    var displayName: String = "원본"

    var systemName: FilterName = .None

    var ciFilter: CIFilter? = nil

    var properties: [FilterPropertyKey : Codable] = [:]
}
