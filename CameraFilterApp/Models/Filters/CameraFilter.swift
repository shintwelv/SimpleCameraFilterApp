//
//  File.swift
//  CameraFilterApp
//
//  Created by siheo on 11/27/23.
//

import Foundation
import CoreImage

enum FilterName: String {
    case None
    case CISepiaTone
    case CIPhotoEffectTransfer
    case CIPhotoEffectTonal
    case CIColorMonochrome
    case CIColorPosterize
    case CIBoxBlur
}

enum FilterPropertyKey: String {
    case inputColor
    case inputIntensity
    case inputRadius
    case inputLevels
}

protocol CameraFilter {
    var filterId: UUID { get }
    var displayName: String { get }
    
    var systemName: FilterName { get }
    
    var ciFilter: CIFilter? { get }
    
    var properties: [FilterPropertyKey : Codable] { get }
}
