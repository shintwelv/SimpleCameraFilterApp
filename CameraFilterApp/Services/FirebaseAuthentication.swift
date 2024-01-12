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
import RxSwift

class FirebaseAuthentication: NSObject, UserAuthenticationProtocol {
    
    private var bag = DisposeBag()

    func loggedInUser() -> Observable<User?> {
        return Observable.create { observer in
            let currentUser = Auth.auth().currentUser
            
            if let currentUser = currentUser {
                let user = User(userId: currentUser.uid, email: currentUser.email ?? "")
                observer.onNext(user)
            } else {
                observer.onNext(nil)
            }
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    private var currentNonce: String?
    private var appleLoginObserver: PublishSubject<User>?
    private weak var appleLoginPresentingController: UIViewController?
    
    private func resetAppleLoginInfo() {
        currentNonce = nil
        if let appleLoginObserver = appleLoginObserver {
            appleLoginObserver.dispose()
        }
        appleLoginObserver = nil
        appleLoginPresentingController = nil
    }
    
    func appleLogin(presentingViewController vc: UIViewController) -> Observable<User> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(UserAuthenticationError.cannotLogIn("self is not referenced"))
                return Disposables.create()
            }
            
            self.resetAppleLoginInfo()
            
            self.appleLoginObserver = PublishSubject()
            let subscription = self.appleLoginObserver?
                .subscribe(
                    onNext: { user in
                        observer.onNext(user)
                    },
                    onError: { error in
                        observer.onError(error)
                    }
                )
            
            guard let nonce = randomNonceString() else {
                observer.onError(UserAuthenticationError.cannotLogIn("nonce를 생성할 수 없습니다"))
                return Disposables.create()
            }
            
            self.currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.email]
            request.nonce = self.sha256(nonce)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
            
            
            return Disposables.create {
                subscription?.dispose()
            }
        }
    }
    
    func googleLogin(presentingViewController vc: UIViewController) -> Observable<User> {
        return Observable<User>.create { observer in
            
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                observer.onError(UserAuthenticationError.cannotLogIn("ClientID is not found"))
                return Disposables.create()
            }
            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            GIDSignIn.sharedInstance.signIn(withPresenting: vc) { [weak self] result, error in
                guard let self = self else {
                    observer.onError(UserAuthenticationError.cannotLogIn("self is not referenced"))
                    return
                }
                
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let user = result?.user,
                        let idToken = user.idToken?.tokenString else {
                    observer.onError(UserAuthenticationError.cannotLogIn("User를 받아오는 데 실패했습니다"))
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                
                self.login(with: credential)
                    .subscribe(
                        onNext: { authResult in
                            guard let authResult = authResult else {
                                observer.onError(UserAuthenticationError.cannotLogIn("로그인할 수 없습니다"))
                                return
                            }
                            
                            let loggedUser = User(userId: authResult.user.uid, email: authResult.user.email ?? "")
                            observer.onNext(loggedUser)
                            observer.onCompleted()
                        },
                        onError: { error in
                            observer.onError(error)
                        }
                    )
                    .disposed(by: self.bag)
            }
            
            return Disposables.create()
        }
        
    }
    
    private func login(with credential: AuthCredential) -> Observable<AuthDataResult?> {
        return Observable<AuthDataResult?>.create { observer in
            Auth.auth().signIn(with: credential) { authDataResult, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                if let authDataResult = authDataResult {
                    observer.onNext(authDataResult)
                }
                
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }

    func logIn(email: String, password: String) -> Observable<User> {
        return Observable<User>.create { observer in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let authResult = authResult else {
                    observer.onError(UserAuthenticationError.cannotLogIn("로그인할 수 없습니다"))
                    return
                }
                
                let loggedUser = User(userId: authResult.user.uid, email: authResult.user.email ?? "")
                observer.onNext(loggedUser)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func logOut() -> Observable<User> {
        return Observable<User>.create { observer in
            let FIRUser = Auth.auth().currentUser
            
            if let FIRUser = FIRUser {
                let user = User(userId: FIRUser.uid, email: FIRUser.email ?? "")
                do {
                    try Auth.auth().signOut()
                    observer.onNext(user)
                    observer.onCompleted()
                } catch let signOutError as NSError {
                    observer.onError(signOutError)
                }
            } else {
                observer.onError(UserAuthenticationError.cannotLogOut("로그인 상태가 아닙니다"))
            }
            
            return Disposables.create()
        }
    }
    
    func signUp(email: String, password: String) -> Observable<User> {
        return Observable<User>.create { observer in
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let authResult = authResult else {
                    observer.onError(UserAuthenticationError.cannotSignUp("계정을 생성할 수 없습니다"))
                    return
                }
                
                let loggedInUser = User(userId: authResult.user.uid, email: authResult.user.email ?? "")
                observer.onNext(loggedInUser)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func delete() -> Observable<User> {
        return Observable<User>.create { observer in
            
            let currentUser = Auth.auth().currentUser
            
            if let currentUser = currentUser {
                currentUser.delete(completion: { error in
                    if let error = error {
                        observer.onError(error)
                    }
                    
                    let deletedUser = User(userId: currentUser.uid, email: currentUser.email ?? "")
                    observer.onNext(deletedUser)
                    observer.onCompleted()
                })
            } else {
                observer.onError(UserAuthenticationError.cannotDelete("로그인이 되어 있지 않습니다"))
            }
            
            return Disposables.create()
        }
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
        guard let appleLoginObserver = self.appleLoginObserver else {
            return
        }
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            appleLoginObserver.onError(UserAuthenticationError.cannotLogIn("AppleID의 credential이 존재하지 않습니다"))
            return
        }
        
        guard let nonce = currentNonce else {
            appleLoginObserver.onError(UserAuthenticationError.cannotLogIn("비정상적인 로그인 응답입니다"))
            return
        }
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            appleLoginObserver.onError(UserAuthenticationError.cannotLogIn("토큰을 받아올 수 없습니다"))
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            appleLoginObserver.onError(UserAuthenticationError.cannotLogIn("토큰을 변환할 수 없습니다"))
            return
        }
        
        let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                       rawNonce: nonce,
                                                       fullName: appleIDCredential.fullName)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                appleLoginObserver.onError(error)
                return
            }
            
            guard let authResult = authResult else {
                appleLoginObserver.onError(UserAuthenticationError.cannotLogIn("계정을 생성할 수 없습니다"))
                return
            }
            
            let loggedInUser = User(userId: authResult.user.uid, email: authResult.user.email ?? "")
            appleLoginObserver.onNext(loggedInUser)
            appleLoginObserver.onCompleted()
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard let appleLoginObserver = self.appleLoginObserver else {
            return
        }
        
        appleLoginObserver.onError(error)
    }
}

extension FirebaseAuthentication: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let appleLoginPresentingController = appleLoginPresentingController,
            let window = appleLoginPresentingController.view.window else {
            return UIApplication.shared.windows.last(where: \.isKeyWindow) ?? ASPresentationAnchor()
        }
        
        return window
    }
}
