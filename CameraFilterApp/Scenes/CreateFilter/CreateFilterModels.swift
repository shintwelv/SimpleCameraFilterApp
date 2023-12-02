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
    typealias FilterProperty = (min:CGFloat, max:CGFloat, value:CGFloat)

    struct FilterInfo {
        var filterName: String?
        
        var filterSystemName: FilterName?

        var inputColor: UIColor?
        var inputIntensity: FilterProperty?
        var inputRadius: FilterProperty?
        var inputLevels: FilterProperty?
    }
    
    enum FetchFilter {
        struct Request {
            
        }
        struct Response {
            var filter: CameraFilter
        }
        struct ViewModel {
            var filterInfo: FilterInfo?
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
            var filterSystemName: FilterName
        }
        struct Response {
            var inputColor: UIColor?
            var inputIntensity: FilterProperty?
            var inputRadius: FilterProperty?
            var inputLevels: FilterProperty?
        }
        struct ViewModel {
            var inputColor: UIColor?
            var inputIntensity: FilterProperty?
            var inputRadius: FilterProperty?
            var inputLevels: FilterProperty?
        }
    }
    
    enum CreateFilter {
        struct Request {
            var filterName: String
            
            var filterSystemName: FilterName
            
            var inputColor: UIColor?
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
            var filterName: String
            
            var filterSystemName: FilterName
            
            var inputColor: UIColor?
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
    
    enum DeleteFilter {
        struct Request {
            
        }
        struct Response {
            var filter: CameraFilter?
        }
        struct ViewModel {
            var filterInfo: FilterInfo?
        }
    }
}
