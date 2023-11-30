//
//  CyanFilter.swift
//  CameraFilterApp
//
//  Created by siheo on 11/27/23.
//

import Foundation
import CoreImage

class CyanFilter: MonochromeFilter {
    init?(inputIntensity: CGFloat = 1.0) {
        super.init(displayName: "시안", inputColor: CIColor.cyan, inputIntensity: inputIntensity)
    }
}
