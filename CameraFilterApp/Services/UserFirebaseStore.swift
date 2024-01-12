//
//  UserFirebaseStore.swift
//  CameraFilterApp
//
//  Created by siheo on 1/3/24.
//

import Foundation
import NetworkManager
import RxSwift

class UserFirebaseStore: UserStoreProtocol {
    
    struct URLManager {
        private init() {}
        
        static let endPoint: String = FirebaseDB.Endpoint.url.rawValue + "/" + FirebaseDB.Name.users.rawValue
        
        static let usersJson: String = endPoint + "." + FirebaseDB.FileExt.json.rawValue
        
        static func fetchUserURL(userId: String) -> String {
            return usersJson + "?"
            + FirebaseDB.OrderBy.key.description + "&"
            + FirebaseDB.Filtering.equalTo(param: userId).description
        }
        
        static func createUserURL() -> String {
            return usersJson
        }
        
        static func deleteUserURL(userId: String) -> String {
            return endPoint + "/"
            + userId + "."
            + FirebaseDB.FileExt.json.rawValue
        }
    }
    
    enum ParamKey:String {
        case email
    }
    
    typealias UserData = [String: [String : String]]
    
    func fetchUserInStore(userToFetch: User) -> Observable<User?> {
        return Observable<User?>.create { observer in
            
            let url: String = URLManager.fetchUserURL(userId: userToFetch.userId)
            
            let subscription = NetworkManager.shared.getMethod(url)?
                .decodableResponse(of: UserData.self)
                .subscribe(
                    onNext: { [weak self] data in
                        guard let self = self else {
                            observer.onError(UserStoreError.cannotFetch("self is not referred"))
                            return
                        }
                        
                        let user: User? = self.createUser(userId: data.keys.first, userData: data)
                        observer.onNext(user)
                        observer.onCompleted()
                    },
                    onError: { error in
                        observer.onError(error)
                    }
                )
            
            return Disposables.create {
                guard let subscription = subscription else { return }
                subscription.dispose()
            }
        }
    }
    
    func createUserInStore(userToCreate: User) -> Observable<User> {
        return Observable<User>.create { [weak self] observer in
            guard let self = self else {
                observer.onError(UserStoreError.cannotCreate("self is not referred"))
                return Disposables.create()
            }
            
            let parameter: UserData = self.createParams(user: userToCreate)
            
            let headers: [HTTPRequestHeaderKey : HTTPRequestHeaderValue] = [
                .contentType : .applicationJson
            ]
            
            let url:String = URLManager.createUserURL()
            
            let subscription = NetworkManager.shared.patchMethod(url, headers: headers, parameters: parameter, encoding: .json)?
                .decodableResponse(of: UserData.self)
                .subscribe(
                    onNext: { data in
                        
                        guard let user = self.createUser(userId: data.keys.first, userData: data) else {
                            observer.onError(UserStoreError.cannotCreate("유저를 생성할 수 없습니다"))
                            return
                        }
                        
                        observer.onNext(user)
                        observer.onCompleted()
                    },
                    onError: { error in
                        observer.onError(error)
                    }
                )
            
            return Disposables.create {
                guard let subscription = subscription else { return }
                subscription.dispose()
            }
        }
    }
    
    func deleteUserInStore(userToDelete: User) -> Observable<User> {
        
        return Observable<User>.create { observer in
            
            let url: String = URLManager.deleteUserURL(userId: userToDelete.userId)
            
            let subscription = NetworkManager.shared.deleteMethod(url)?
                .response()
                .subscribe(
                    onNext: { _ in
                        observer.onNext(userToDelete)
                        observer.onCompleted()
                    },
                    onError: { error in
                        observer.onError(error)
                    }
                )
            
            return Disposables.create {
                guard let subscription = subscription else { return }
                subscription.dispose()
            }
        }
    }
    
    private func createParams(user: User) -> UserData {
        return [
            user.userId: [
                ParamKey.email.rawValue: user.email,
            ]
        ]
    }
    
    private func createUser(userId: String?, userData:[String : [String : String]]) -> User? {
        guard let userId = userId,
              let userData: [String: String] = userData[userId],
              let email = userData[ParamKey.email.rawValue] else { return nil }
        
        return User(userId: userId, email: email)
    }
}
