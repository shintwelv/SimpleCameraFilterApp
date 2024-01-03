//
//  File.swift
//  CameraFilterApp
//
//  Created by siheo on 11/27/23.
//

import Foundation
import CoreImage

struct CameraFilter {
    enum FilterName: String, CaseIterable {
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
    
    let filterId: UUID
    var displayName: String
    
    var systemName: FilterName
    
    var ciFilter: CIFilter
    
    var inputColor: CIColor? {
        didSet {
            if self.systemName == .CIColorMonochrome {
                self.ciFilter.setValue(self.inputColor, forKey: FilterPropertyKey.inputColor.rawValue)
            }
        }
    }
    
    var inputIntensity: CGFloat? {
        didSet {
            if self.systemName == .CIColorMonochrome || self.systemName == .CISepiaTone {
                self.ciFilter.setValue(self.inputIntensity, forKey: FilterPropertyKey.inputIntensity.rawValue)
            }
        }
    }
    
    var inputRadius: CGFloat? {
        didSet {
            if self.systemName == .CIBoxBlur {
                self.ciFilter.setValue(self.inputRadius, forKey: FilterPropertyKey.inputRadius.rawValue)
            }
        }
    }
    
    var inputLevels: CGFloat? {
        didSet {
            if self.systemName == .CIColorPosterize {
                self.ciFilter.setValue(self.inputLevels, forKey: FilterPropertyKey.inputLevels.rawValue)
            }
        }
    }
    
    private init(filterId: UUID, displayName: String, systemName: FilterName, ciFilter: CIFilter, inputColor: CIColor? = nil, inputIntensity: CGFloat? = nil, inputRadius: CGFloat? = nil, inputLevels: CGFloat? = nil) {
        self.filterId = filterId
        self.displayName = displayName
        self.systemName = systemName
        self.ciFilter = ciFilter
        self.inputColor = inputColor
        self.inputIntensity = inputIntensity
        self.inputRadius = inputRadius
        self.inputLevels = inputLevels
    }
}

extension CameraFilter {
    static func createSepiaFilter(filterId: UUID, displayName:String, inputIntensity: CGFloat) -> CameraFilter? {
        guard let filter = CIFilter(name: FilterName.CISepiaTone.rawValue) else { return nil }
        filter.setValue(inputIntensity, forKey: FilterPropertyKey.inputIntensity.rawValue)
        
        return CameraFilter(filterId: filterId, displayName: displayName, systemName: .CISepiaTone, ciFilter: filter, inputIntensity: inputIntensity)
    }
    
    static func createVintageFilter(filterId: UUID, displayName: String) -> CameraFilter? {
        guard let filter = CIFilter(name: FilterName.CIPhotoEffectTransfer.rawValue) else { return nil }
        
        return CameraFilter(filterId: filterId, displayName: displayName, systemName: .CIPhotoEffectTransfer, ciFilter: filter)
    }
    
    static func createBlackWhiteFilter(filterId: UUID, displayName: String) -> CameraFilter? {
        guard let filter = CIFilter(name: FilterName.CIPhotoEffectTonal.rawValue) else { return nil }
        
        return CameraFilter(filterId: filterId, displayName: displayName, systemName: .CIPhotoEffectTonal, ciFilter: filter)
    }
    
    static func createMonochromeFilter(filterId: UUID, displayName: String, inputColor: CIColor, inputIntensity: CGFloat) -> CameraFilter? {
        guard let filter = CIFilter(name: FilterName.CIColorMonochrome.rawValue) else { return nil }
        filter.setValue(inputColor, forKey: FilterPropertyKey.inputColor.rawValue)
        filter.setValue(inputIntensity, forKey: FilterPropertyKey.inputIntensity.rawValue)
        
        return CameraFilter(filterId: filterId, displayName: displayName, systemName: .CIColorMonochrome, ciFilter: filter, inputColor: inputColor, inputIntensity: inputIntensity)
    }
    
    static func createBlurFilter(filterId: UUID, displayName: String, inputRadius: CGFloat) -> CameraFilter? {
        guard let filter = CIFilter(name: FilterName.CIBoxBlur.rawValue) else { return nil }
        filter.setValue(inputRadius, forKey: FilterPropertyKey.inputRadius.rawValue)
        
        return CameraFilter(filterId: filterId, displayName: displayName, systemName: .CIBoxBlur, ciFilter: filter, inputRadius: inputRadius)
    }
    
    static func createPosterizeFilter(filterId: UUID, displayName: String, inputLevels: CGFloat) -> CameraFilter? {
        guard let filter = CIFilter(name: FilterName.CIColorPosterize.rawValue) else { return nil }
        filter.setValue(inputLevels, forKey: FilterPropertyKey.inputLevels.rawValue)
        
        return CameraFilter(filterId: filterId, displayName: displayName, systemName: .CIColorPosterize, ciFilter: filter, inputLevels: inputLevels)
    }
}
