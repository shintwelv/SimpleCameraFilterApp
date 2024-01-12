//
//  UserWorker.swift
//  CameraFilterApp
//
//  Created by siheo on 1/3/24.
//

import Foundation
import UIKit
import RxSwift

class UserWorker {
    
    var storeProvider: UserStoreProtocol
    var authenticationProvider: UserAuthenticationProtocol
    
    init(store: UserStoreProtocol, authentication: UserAuthenticationProtocol) {
        self.storeProvider = store
        self.authenticationProvider = authentication
    }
    
    // MARK: - Authenticate
    func fetchCurrentlyLoggedInUser() -> Observable<User?> {
        return authenticationProvider.loggedInUser()
    }
    
    func authenticateThroughApple(presentingViewController vc: UIViewController) -> Observable<User> {
        return authenticationProvider.appleLogin(presentingViewController: vc)
    }
    
    func authenticateThroughGoogle(presentingViewController vc: UIViewController) -> Observable<User> {
        return authenticationProvider.googleLogin(presentingViewController: vc)
    }
    
    func logIn(email: String, password: String) -> Observable<User> {
        return authenticationProvider.logIn(email: email, password: password)
    }
    
    func logOut() -> Observable<User> {
        return authenticationProvider.logOut()
    }
    
    func signUp(email: String, password: String) -> Observable<User> {
        return authenticationProvider.signUp(email: email, password: password)
    }
    
    func removeAuthentication() -> Observable<User> {
        return authenticationProvider.delete()
    }
    
    // MARK: - DB Interaction
    func findInDB(_ user: User) -> Observable<User?> {
        return storeProvider.fetchUserInStore(userToFetch: user)
    }
    
    func saveInDB(_ user: User) -> Observable<User> {
        return storeProvider.createUserInStore(userToCreate: user)
    }
    
    func deleteFromDB(_ user: User) -> Observable<User> {
        return storeProvider.deleteUserInStore(userToDelete: user)
    }
}

protocol UserStoreProtocol {
    func fetchUserInStore(userToFetch:User) -> Observable<User?>
    func createUserInStore(userToCreate: User) -> Observable<User>
    func deleteUserInStore(userToDelete: User) -> Observable<User>
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
    func loggedInUser() -> Observable<User?>
    func logIn(email: String, password: String) -> Observable<User>
    func appleLogin(presentingViewController: UIViewController) -> Observable<User>
    func googleLogin(presentingViewController: UIViewController) -> Observable<User>
    func logOut() -> Observable<User>
    func signUp(email: String, password: String) -> Observable<User>
    func delete() -> Observable<User>
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
