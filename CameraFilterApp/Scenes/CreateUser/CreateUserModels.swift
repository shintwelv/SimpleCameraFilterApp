//
//  CreateUserModels.swift
//  CameraFilterApp
//
//  Created by siheo on 12/18/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

enum CreateUser
{
  // MARK: Use cases

    enum UserAuthError: Equatable, LocalizedError {
        case cannotSignIn(String)
        case cannotSignUp(String)
        case cannotSignOut(String)
        case cannotCheckLogin(String)
        
        var errorDescription: String? {
            switch self {
            case .cannotSignOut(let string), .cannotSignIn(let string), .cannotSignUp(let string), .cannotCheckLogin(let string):
                return string
            }
        }
        
        static func ==(lhs: UserAuthError, rhs: UserAuthError) -> Bool {
            switch (lhs, rhs) {
            case (.cannotSignIn(let a), .cannotSignIn(let b)) where a == b: return true
            case (.cannotSignUp(let a), .cannotSignUp(let b)) where a == b: return true
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
    
    enum GoogleSignIn {
        struct Request {
            weak var presentingViewController: UIViewController?
        }
        struct Response {
            var signedInUser: UserResult<User>
        }
        struct ViewModel {
            var signedInUserEmail: String?
        }
    }
    
    enum SignIn {
        struct Request {
            var userEmail: String
            var userPassword: String
        }
        struct Response {
            var signedInUser: UserResult<User>
        }
        struct ViewModel {
            var signedInUserEmail: String?
        }
    }
    
    enum SignUp {
        struct Request {
            var newEmail: String
            var newPassword: String
        }
        struct Response {
            var createdUser: UserResult<User>
        }
        struct ViewModel {
            var createdUserEmail: String?
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
}
