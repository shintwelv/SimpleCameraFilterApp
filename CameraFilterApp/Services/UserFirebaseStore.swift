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
        let url: String = URLManager.fetchUserURL(userId: userToFetch.userId)
        
        guard let networkResponse = NetworkManager.shared.getMethod(url) else {
            return Observable.error(UserStoreError.cannotFetch("invalid url"))
        }
        
        return networkResponse.decodableResponse(of: UserData.self)
            .map { [weak self] (userData: UserData) -> User? in
                guard let self = self else {
                    throw UserStoreError.cannotFetch("self is not referred")
                }

                return self.createUser(userId: userData.keys.first, userData: userData)
            }
            .catch { error in
                return Observable<User?>.error(error)
            }
    }
    
    func createUserInStore(userToCreate: User) -> Observable<User> {
        let parameter: UserData = self.createParams(user: userToCreate)
        
        let headers: [HTTPRequestHeaderKey : HTTPRequestHeaderValue] = [
            .contentType : .applicationJson
        ]
        
        let url:String = URLManager.createUserURL()
        
        guard let networkResponse = NetworkManager.shared.patchMethod(url, headers: headers, parameters: parameter, encoding: .json) else {
            return Observable.error(UserStoreError.cannotCreate("invalid request"))
        }
        
        return networkResponse.decodableResponse(of: UserData.self)
            .map { [weak self] (userData: UserData) -> User in
                guard let self = self else {
                    throw UserStoreError.cannotCreate("self is not referred")
                }
                
                guard let user: User = self.createUser(userId: userData.keys.first, userData: userData) else {
                    throw UserStoreError.cannotCreate("유저를 생성할 수 없습니다")
                }
                return user
            }
            .catch { error in
                return Observable<User>.error(error)
            }
    }
    
    func deleteUserInStore(userToDelete: User) -> Observable<User> {
        
        let url: String = URLManager.deleteUserURL(userId: userToDelete.userId)
        
        guard let networkResponse = NetworkManager.shared.deleteMethod(url) else {
            return Observable.error(UserStoreError.cannotDelete("invalid request"))
        }
        
        return networkResponse.response()
            .map { [weak self] _ in
                guard let self = self else {
                    throw UserStoreError.cannotDelete("self is not referred")
                }
                
                return userToDelete
            }
            .catch { error in
                return Observable<User>.error(error)
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
