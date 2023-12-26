//
//  FirebaseAuthentication.swift
//  CameraFilterApp
//
//  Created by siheo on 12/18/23.
//

import Foundation
import FirebaseAuth

class FirebaseAuthentication: UserAuthenticationProtocol {

    func loggedInUser(completionHandler: @escaping (UserAuthenticationResult<User?>) -> Void) {
        let currentUser = Auth.auth().currentUser
        
        if let currentUser = currentUser {
            let user = User(email: currentUser.email ?? "")
            let result = UserAuthenticationResult.Success(result: user as User?)
            completionHandler(result)
        } else {
            let result = UserAuthenticationResult.Success(result: nil as User?)
            completionHandler(result)
        }
    }

    func logIn(email: String, password: String, completionHandler: @escaping (UserAuthenticationResult<User>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                let result = UserAuthenticationResult<User>.Failure(error: .cannotLogIn("\(error)"))
                completionHandler(result)
            }
            
            guard let authResult = authResult else {
                let result = UserAuthenticationResult<User>.Failure(error: .cannotLogIn("로그인할 수 없습니다"))
                completionHandler(result)
                return
            }
            
            let loggedUser = User(email: authResult.user.email ?? "")
            let result = UserAuthenticationResult.Success(result: loggedUser)
            completionHandler(result)
        }
    }
    
    func logOut(completionHandler: @escaping (UserAuthenticationResult<User>) -> Void) {
        let FIRUser = Auth.auth().currentUser
        
        guard let FIRUser = FIRUser else {
            let result: UserAuthenticationResult<User> = UserAuthenticationResult.Failure(error: .cannotLogOut("로그인 상태가 아닙니다"))
            completionHandler(result)
            return
        }

        let user = User(email: FIRUser.email ?? "")
        do {
            try Auth.auth().signOut()
            let result = UserAuthenticationResult.Success(result: user)
            completionHandler(result)
        } catch let signOutError as NSError {
            let result: UserAuthenticationResult<User> = UserAuthenticationResult.Failure(error: .cannotLogOut("\(signOutError)"))
            completionHandler(result)
        }
    }
    
    func signUp(email: String, password: String, completionHandler: @escaping (UserAuthenticationResult<User>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                let result: UserAuthenticationResult<User> = UserAuthenticationResult.Failure(error: .cannotSignUp("\(error)"))
                completionHandler(result)
            }
            
            guard let authResult = authResult else {
                let result: UserAuthenticationResult<User> = UserAuthenticationResult.Failure(error: .cannotSignUp("계정을 생성할 수 없습니다"))
                completionHandler(result)
                return
            }
            
            let loggedInUser = User(email: authResult.user.email ?? "")
            let result = UserAuthenticationResult.Success(result: loggedInUser)
            completionHandler(result)
        }
    }
}
