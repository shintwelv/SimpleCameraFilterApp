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
    enum FilterType {
        case blur
        case monochrome
        case sepia
        case posterize
    }
    
    enum FetchFilter {
        struct Request {
            var filterId: UUID
        }
        struct Response {
            var filter: CameraFilter
        }
        struct ViewModel {
            var filterId: UUID
            var filterName: String
            var properties: [String : Any?]
            var filterType: [FilterType]
        }
    }
    
    enum FetchProperties {
        struct Request {
            var filterType: [FilterType]
        }
        struct Response {
            var properties: [String : Any?]
        }
        struct ViewModel {
            var properties: [String : Any?]
        }
    }
    
    enum CreateFilter {
        struct Request {
            var filterName: String
            var properties: [String : Any?]
        }
        struct Response {
            var filter: CameraFilter?
        }
        struct ViewModel {
            
        }
    }
    
    enum EditFilter {
        struct Request {
            var filterId: UUID
            var newFilterName: String
            var newProperties: [String : Any?]
        }
        struct Response {
            var filter: CameraFilter
        }
        struct ViewModel {
            var filterId: UUID
            var filterName: String
            var properties: [String : Any?]
        }
    }
    
    enum DeleteFilter {
        struct Request {
            var filterId: UUID
        }
        struct Response {
            var success: Bool
        }
        struct ViewModel {
            var success: Bool
            var resultMessage: String
        }
    }
}
