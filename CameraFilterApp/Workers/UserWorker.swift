//
//  UserWorker.swift
//  CameraFilterApp
//
//  Created by siheo on 1/3/24.
//

import Foundation
import Alamofire
import UIKit

class UserWorker {
    
    var storeProvider: UserStoreProtocol
    var authenticationProvider: UserAuthenticationProtocol
    
    init(store: UserStoreProtocol, authentication: UserAuthenticationProtocol) {
        self.storeProvider = store
        self.authenticationProvider = authentication
    }
    
    // MARK: - Authenticate
    func fetchCurrentlyLoggedInUser(completionHandler: @escaping LoggedInUserCompletionHandler) {
        authenticationProvider.loggedInUser(completionHandler: completionHandler)
    }
    
    func authenticateThroughApple(presentingViewController vc: UIViewController, completionHandler: @escaping UserLogInCompletionHandler) {
        authenticationProvider.appleLogin(presentingViewController: vc, completionHandler: completionHandler)
    }
    
    func authenticateThroughGoogle(presentingViewController vc: UIViewController, completionHandler: @escaping UserLogInCompletionHandler) {
        authenticationProvider.googleLogin(presentingViewController: vc, completionHandler: completionHandler)
    }
    
    func logIn(email: String, password: String, completionHandler: @escaping UserLogInCompletionHandler) {
        authenticationProvider.logIn(email: email, password: password, completionHandler: completionHandler)
    }
    
    func logOut(completionHandler: @escaping UserLogOutCompletionHandler) {
        authenticationProvider.logOut(completionHandler: completionHandler)
    }
    
    func signUp(email: String, password: String, completionHandler: @escaping UserSignUpCompletionHandler) {
        authenticationProvider.signUp(email: email, password: password, completionHandler: completionHandler)
    }
    
    func removeAuthentication(completionHandler: @escaping UserDeleteCompletionHandler) {
        authenticationProvider.delete(completionHandler: completionHandler)
    }
    
    // MARK: - DB Interaction
    func findInDB(_ user: User, completionHandler: @escaping UserStoreFetchUserCompletionHandler) {
        storeProvider.fetchUserInStore(userToFetch: user, completionHandler: completionHandler)
    }
    
    func saveInDB(_ user: User, completionHandler: @escaping UserStoreCreateUserCompletionHandler) {
        storeProvider.createUserInStore(userToCreate: user, completionHandler: completionHandler)
    }
    
    func deleteFromDB(_ user: User, completionHandler: @escaping UserStoreDeleteUserCompletionHandler) {
        storeProvider.deleteUserInStore(userToDelete: user, completionHandler: completionHandler)
    }
}

protocol UserStoreProtocol {
    func fetchUserInStore(userToFetch:User, completionHandler: @escaping UserStoreFetchUserCompletionHandler)
    func createUserInStore(userToCreate: User, completionHandler: @escaping UserStoreCreateUserCompletionHandler)
    func deleteUserInStore(userToDelete: User, completionHandler: @escaping UserStoreDeleteUserCompletionHandler)
}

typealias UserStoreFetchUserCompletionHandler = (UserStoreResult<User?>) -> Void
typealias UserStoreDeleteUserCompletionHandler = (UserStoreResult<User>) -> Void
typealias UserStoreCreateUserCompletionHandler = (UserStoreResult<User>) -> Void

enum UserStoreResult<U> {
    case Success(result: U)
    case Failure(error: UserStoreError)
}

enum UserStoreError: Equatable, LocalizedError {
    case cannotFetch(String)
    case cannotDelete(String)
    case cannotCreate(String)
    
    var errorDescription: String? {
        switch self {
        case .cannotFetch(let string), .cannotDelete(let string), .cannotCreate(let string):
            return string
        }
    }
}

func ==(lhs: UserStoreError, rhs: UserStoreError) -> Bool {
    switch (lhs, rhs) {
    case (.cannotFetch(let a), .cannotFetch(let b)) where a == b: return true
    case (.cannotDelete(let a), .cannotDelete(let b)) where a == b: return true
    case (.cannotCreate(let a), .cannotCreate(let b)) where a == b: return true
    default: return false
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
