//
//  File.swift
//  CameraFilterApp
//
//  Created by siheo on 11/27/23.
//

import Foundation
import CoreImage

protocol CameraFilter {
    var filterId: UUID { get }
    var displayName: String { get }
    var ciFilter: CIFilter? { get }
}
