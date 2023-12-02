//
//  CreateFilterModels.swift
//  CameraFilterApp
//
//  Created by siheo on 11/29/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

enum CreateFilter
{
    // MARK: Use cases
    
    struct FilterInfo {
        var filterId: UUID
        var filterName: String
        
        var filterPropertyFields: FilterPropertyFields
    }
    
    struct FilterPropertyFields {
        var inputColor: FilterProperty?
        var inputIntensity: FilterProperty?
        var inputRadius: FilterProperty?
        var inputLevels: FilterProperty?
    }
    
    struct FilterProperty {
        var min: CGFloat
        var currentValue: CGFloat
        var max: CGFloat
    }
    
    enum FetchFilter {
        struct Request {
            var filterId: UUID
        }
        struct Response {
            var filter: CameraFilter
        }
        struct ViewModel {
            var filterInfo: FilterInfo
        }
    }
    
    enum FetchFilterCategories {
        struct Request {
            
        }
        struct Response {
            var filterCategories: [FilterName]
        }
        struct ViewModel {
            var filterCategories: [String]
        }
    }
    
    enum FetchProperties {
        struct Request {
            var filterType: [FilterName]
        }
        struct Response {
            var filterPropertyFields: FilterPropertyFields
        }
        struct ViewModel {
            var filterPropertyFields: FilterPropertyFields
        }
    }
    
    enum CreateFilter {
        struct Request {
            var filterName: String
            
            var filterSystemName: FilterName
            
            var inputColor: CGColor?
            var inputIntensity: CGFloat?
            var inputRadius: CGFloat?
            var inputLevels: CGFloat?
        }
        struct Response {
            var filter: CameraFilter?
        }
        struct ViewModel {
            var filterInfo: FilterInfo?
        }
    }
    
    enum EditFilter {
        struct Request {
            var filterInfo: FilterInfo
        }
        struct Response {
            var filter: CameraFilter?
        }
        struct ViewModel {
            var filterInfo: FilterInfo?
        }
    }
    
    enum DeleteFilter {
        struct Request {
            var filterId: UUID
        }
        struct Response {
            var filter: CameraFilter?
        }
        struct ViewModel {
            var filterInfo: FilterInfo?
        }
    }
}
