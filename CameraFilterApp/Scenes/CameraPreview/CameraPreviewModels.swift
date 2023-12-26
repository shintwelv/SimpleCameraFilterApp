//
//  CameraPreviewModels.swift
//  CameraFilterApp
//
//  Created by siheo on 11/27/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import MetalKit

enum CameraPreview
{
    // MARK: Use cases
    
    enum UserAuthError: Equatable, LocalizedError {
        case cannotSignOut(String)
        case cannotCheckLogin(String)
        
        var errorDescription: String? {
            switch self {
            case .cannotSignOut(let string), .cannotCheckLogin(let string):
                return string
            }
        }
        
        static func ==(lhs: UserAuthError, rhs: UserAuthError) -> Bool {
            switch (lhs, rhs) {
            case (.cannotSignOut(let a), .cannotSignOut(let b)) where a == b: return true
            case (.cannotCheckLogin(let a), .cannotCheckLogin(let b)) where a == b: return true
            default: return false
            }
        }
    }
    
    enum UserResult<U> {
        case Success(result: U)
        case Failure(error: UserAuthError)
    }
    
    enum LoginStatus {
        struct Request {
        }
        struct Response {
            var signedInUser: UserResult<User?>
        }
        struct ViewModel {
            var signedInUserEmail: String?
        }
    }
    
    enum SignOut {
        struct Request {
        }
        struct Response {
            var signedOutUser: UserResult<User>
        }
        struct ViewModel {
            var signedOutUserEmail: String?
        }
    }
    
    struct FilterInfo {
        var filterId: UUID
        var filterName: String
    }
    
    enum TakePhoto {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum StartSession {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum PauseSession {
        struct Request {
        }
    }
    
    enum FetchFilters {
        struct Request {
        }
        struct Response {
            var filters: [CameraFilter]
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
            
        }
        struct ViewModel {
            
        }
    }
    
    enum DrawFrameImage {
        struct Request {
        }
        struct Response {
            var frameImage: CIImage
            var commandBuffer: MTLCommandBuffer
        }
        struct ViewModel {
            var frameImage: CIImage
            var commandBuffer: MTLCommandBuffer
        }
    }
    
    enum SelectPhoto {
        struct Request {
            var photo: UIImage
        }
    }
}
