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
        var sampleImage: UIImage?
        
        var filterName: String
        
        var filterSystemName: CameraFilter.FilterName

        var inputColor: UIColor?
        var inputIntensity: FilterProperty?
        var inputRadius: FilterProperty?
        var inputLevels: FilterProperty?
    }
    
    enum FilterOperation {
        case fetch
        case edit
        case create
        case delete
    }
    
    enum FilterError: Error {
        case cannotFetch(String)
        case cannotCreate(String)
        case cannotEdit(String)
        case cannotDelete(String)
    }
    
    enum FilterInfoResult {
        case Success(operation:FilterOperation, result: FilterInfo)
        case Fail(error: FilterError)
    }
    
    enum FetchFilter {
        struct Request {
            
        }
        struct Response {
            var filter: CameraFilter?
        }
        struct ViewModel {
            var sampleImage: UIImage?
            var filterInfo: FilterInfo?
        }
    }
    
    enum FetchFilterCategories {
        struct Request {
            
        }
        struct Response {
            var filterCategories: [CameraFilter.FilterName]
        }
        struct ViewModel {
            var filterCategories: [String]
        }
    }
    
    enum FetchProperties {
        struct Request {
            var filterSystemName: CameraFilter.FilterName
        }
        struct Response {
            var defaultFilter: CameraFilter?
        }
        struct ViewModel {
            var inputColor: UIColor?
            var inputIntensity: FilterProperty?
            var inputRadius: FilterProperty?
            var inputLevels: FilterProperty?
        }
    }
    
    enum ApplyFilter {
        struct Request {
            var filterSystemName: CameraFilter.FilterName
            
            var inputColor: UIColor?
            var inputIntensity: CGFloat?
            var inputRadius: CGFloat?
            var inputLevels: CGFloat?
        }
        struct Response {
            var filter: CameraFilter?
        }
        struct ViewModel {
            var filteredImage: UIImage?
        }
    }
    
    enum CreateFilter {
        struct Request {
            var filterName: String
            
            var filterSystemName: CameraFilter.FilterName
            
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
            
            var filterSystemName: CameraFilter.FilterName
            
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
