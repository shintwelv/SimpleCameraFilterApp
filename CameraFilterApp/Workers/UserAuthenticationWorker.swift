//
//  UserAuthenticationWorker.swift
//  CameraFilterApp
//
//  Created by siheo on 12/18/23.
//

import Foundation
import Alamofire
import UIKit

class UserAuthenticationWorker {
    
    static let endPoint: String =
    FirebaseDB.Endpoint.url.rawValue + FirebaseDB.Name.users.rawValue
    
    var authenticationProvider: UserAuthenticationProtocol
    
    init(provider: UserAuthenticationProtocol) {
        self.authenticationProvider = provider
    }
    
    func loggedInUser(completionHandler: @escaping LoggedInUserCompletionHandler) {
        authenticationProvider.loggedInUser(completionHandler: completionHandler)
    }
    
    func appleLogin(presentingViewController vc: UIViewController, completionHandler: @escaping UserLogInCompletionHandler) {
        authenticationProvider.appleLogin(presentingViewController: vc, completionHandler: completionHandler)
    }
    
    func googleLogin(presentingViewController vc: UIViewController, completionHandler: @escaping UserLogInCompletionHandler) {
        authenticationProvider.googleLogin(presentingViewController: vc, completionHandler: completionHandler)
    }
    
    func login(email: String, password: String, completionHandler: @escaping UserLogInCompletionHandler) {
        authenticationProvider.logIn(email: email, password: password, completionHandler: completionHandler)
    }
    
    func logOut(completionHandler: @escaping UserLogOutCompletionHandler) {
        authenticationProvider.logOut(completionHandler: completionHandler)
    }
    
    func signUp(email: String, password: String, completionHandler: @escaping UserSignUpCompletionHandler) {
        authenticationProvider.signUp(email: email, password: password) { result in
            switch result {
            case .Success(let user):
                var parameter:[String: [String:String]] = [:]
                parameter[user.userId] = ["email" : user.email]
                
                let headers: HTTPHeaders = [
                    .contentType(FirebaseDB.ContentType.applicationJson.rawValue)
                ]
                
                let _ = AF.request("\(UserAuthenticationWorker.endPoint).\(FirebaseDB.FileExt.json)", method: .patch, parameters: parameter, encoder: JSONParameterEncoder.default, headers: headers).response
            case .Failure(_):
                break
            }
            
            completionHandler(result)
        }
    }
    
    func deleteUser(completionHandler: @escaping UserDeleteCompletionHandler) {
        authenticationProvider.delete(completionHandler: completionHandler)
    }
}

protocol UserAuthenticationProtocol {
    func loggedInUser(completionHandler: @escaping LoggedInUserCompletionHandler)
    func logIn(email: String, password: String, completionHandler: @escaping UserLogInCompletionHandler)
    func appleLogin(presentingViewController: UIViewController, completionHandler: @escaping UserLogInCompletionHandler)
    func googleLogin(presentingViewController: UIViewController, completionHandler: @escaping UserLogInCompletionHandler)
    func logOut(completionHandler: @escaping UserLogOutCompletionHandler)
    func signUp(email: String, password: String, completionHandler: @escaping UserSignUpCompletionHandler)
    func delete(completionHandler: @escaping UserDeleteCompletionHandler)
}

typealias LoggedInUserCompletionHandler = (UserAuthenticationResult<User?>) -> Void
typealias UserDeleteCompletionHandler = (UserAuthenticationResult<User>) -> Void
typealias UserLogInCompletionHandler = (UserAuthenticationResult<User>) -> Void
typealias UserLogOutCompletionHandler = (UserAuthenticationResult<User>) -> Void
typealias UserSignUpCompletionHandler = (UserAuthenticationResult<User>) -> Void

enum UserAuthenticationResult<U> {
    case Success(result: U)
    case Failure(error: UserAuthenticationError)
}

enum UserAuthenticationError: Equatable, LocalizedError {
    case cannotLogIn(String)
    case cannotSignUp(String)
    case cannotLogOut(String)
    case cannotDelete(String)
    
    var errorDescription: String? {
        switch self {
        case .cannotLogIn(let string), .cannotSignUp(let string), .cannotLogOut(let string), .cannotDelete(let string):
            return string
        }
    }
}

func ==(lhs: UserAuthenticationError, rhs: UserAuthenticationError) -> Bool {
    switch (lhs, rhs) {
    case (.cannotLogIn(let a), .cannotLogIn(let b)) where a == b: return true
    case (.cannotSignUp(let a), .cannotSignUp(let b)) where a == b: return true
    case (.cannotLogOut(let a), .cannotLogOut(let b)) where a == b: return true
    case (.cannotDelete(let a), .cannotDelete(let b)) where a == b: return true
    default: return false
    }
}
