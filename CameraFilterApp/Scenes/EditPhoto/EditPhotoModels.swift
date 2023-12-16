//
//  EditPhotoModels.swift
//  CameraFilterApp
//
//  Created by siheo on 12/15/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

enum EditPhoto
{
    // MARK: Use cases
    
    struct FilterInfo {
        var filterId: UUID
        var filterName: String
        
        var sampleImage: UIImage
    }
    
    enum FetchFilters {
        struct Request {
        }
        struct Response {
            var cameraFilters: [CameraFilter]
        }
        struct ViewModel {
            var filterInfos: [FilterInfo]
        }
    }
    
    enum ApplyFilter {
        struct Request {
            var filterId: UUID
        }
        struct Response {
            var photo: UIImage
            var cameraFilter: CameraFilter?
        }
        struct ViewModel {
            var filterAppliedPhoto: UIImage
        }
    }
    
    enum SavePhotoResult <U> {
        case Success(result: U)
        case Failure(SavePhotoError)
    }
    
    enum SavePhotoError: LocalizedError, Equatable {
        case cannotSave(String)
        case noCIImage(String)
        case cannotConvert(String)
        
        var errorDescription: String? {
            switch self {
            case .cannotSave(let string):
                return string
            case .noCIImage(let string):
                return string
            case .cannotConvert(let string):
                return string
            }
        }
    }
    
    enum SavePhoto {
        struct Request {
            var filterAppliedPhoto: UIImage
        }
        struct Response {
            var savePhotoResult: SavePhotoResult<UIImage>
        }
        struct ViewModel {
            var savePhotoResult: SavePhotoResult<UIImage>
        }
    }
}
