//
//  FirebaseAuthentication.swift
//  CameraFilterApp
//
//  Created by siheo on 12/18/23.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

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
    
    func googleLogin(presentingViewController vc: UIViewController, completionHandler: @escaping UserLogInCompletionHandler) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                let result = UserAuthenticationResult<User>.Failure(error: .cannotLogIn("\(error)"))
                completionHandler(result)
            }
            
            guard let user = result?.user, 
                let idToken = user.idToken?.tokenString else {
                let result = UserAuthenticationResult<User>.Failure(error: .cannotLogIn("User를 받아오는 데 실패했습니다"))
                completionHandler(result)
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            self.login(with: credential, handler: { authResult, error in
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
            })
        }
    }
    
    private func login(with credential: AuthCredential, handler: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(with: credential, completion: handler)
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
