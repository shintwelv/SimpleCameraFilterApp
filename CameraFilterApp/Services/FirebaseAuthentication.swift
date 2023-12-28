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
import AuthenticationServices
import CryptoKit

class FirebaseAuthentication: NSObject, UserAuthenticationProtocol {

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
    
    private var currentNonce: String?
    private var appleLoginCompletionHandler: UserLogInCompletionHandler?
    private weak var appleLoginPresentingController: UIViewController?
    
    private func resetAppleLoginInfo() {
        currentNonce = nil
        appleLoginCompletionHandler = nil
        appleLoginPresentingController = nil
    }
    
    func appleLogin(presentingViewController vc: UIViewController, completionHandler: @escaping UserLogInCompletionHandler) {
        resetAppleLoginInfo()
        
        guard let nonce = randomNonceString() else {
            let result = UserAuthenticationResult<User>.Failure(error: .cannotLogIn("nonce를 생성할 수 없습니다"))
            completionHandler(result)
            return
        }
        
        self.appleLoginCompletionHandler = completionHandler
        
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
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
    
    func delete(completionHandler: @escaping UserDeleteCompletionHandler) {
        let currentUser = Auth.auth().currentUser
        
        guard let currentUser = currentUser else {
            let result = UserAuthenticationResult<User>.Failure(error: .cannotDelete("로그인이 되어 있지 않습니다"))
            completionHandler(result)
            return
        }
        
        currentUser.delete(completion: { error in
            if let error = error {
                let result = UserAuthenticationResult<User>.Failure(error: .cannotDelete("\(error)"))
                completionHandler(result)
            }
            
            let deletedUser = User(email: currentUser.email ?? "")
            let result = UserAuthenticationResult.Success(result: deletedUser)
            completionHandler(result)
        })
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func randomNonceString(length: Int = 32) -> String? {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            print("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            return nil
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
}

extension FirebaseAuthentication: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleLoginCompletionHandler = self.appleLoginCompletionHandler else {
            return
        }
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            let result = UserAuthenticationResult<User>.Failure(error: .cannotLogIn("AppleID의 credential이 존재하지 않습니다"))
            appleLoginCompletionHandler(result)
            return
        }
        
        guard let nonce = currentNonce else {
            let result = UserAuthenticationResult<User>.Failure(error: .cannotLogIn("비정상적인 로그인 응답입니다"))
            appleLoginCompletionHandler(result)
            return
        }
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            let result = UserAuthenticationResult<User>.Failure(error: .cannotLogIn("토큰을 받아올 수 없습니다"))
            appleLoginCompletionHandler(result)
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            let result = UserAuthenticationResult<User>.Failure(error: .cannotLogIn("토큰을 변환할 수 없습니다"))
            appleLoginCompletionHandler(result)
            return
        }
        
        let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                       rawNonce: nonce,
                                                       fullName: appleIDCredential.fullName)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                let result = UserAuthenticationResult<User>.Failure(error: .cannotLogIn("\(error)"))
                appleLoginCompletionHandler(result)
                return
            }
            
            guard let authResult = authResult else {
                let result: UserAuthenticationResult<User> = UserAuthenticationResult.Failure(error: .cannotLogIn("계정을 생성할 수 없습니다"))
                appleLoginCompletionHandler(result)
                return
            }
            
            let loggedInUser = User(email: authResult.user.email ?? "")
            let result = UserAuthenticationResult.Success(result: loggedInUser)
            appleLoginCompletionHandler(result)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard let appleLoginCompletionHandler = self.appleLoginCompletionHandler else {
            return
        }
        
        let result: UserAuthenticationResult<User> = UserAuthenticationResult.Failure(error: .cannotLogIn("\(error)"))
        appleLoginCompletionHandler(result)
    }
}

extension FirebaseAuthentication: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let appleLoginPresentingController = appleLoginPresentingController,
            let window = appleLoginPresentingController.view.window else {
            return ASPresentationAnchor()
        }
        
        return window
    }
}
