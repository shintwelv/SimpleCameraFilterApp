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
    
    private var disposebag = DisposeBag()
    
    typealias UserData = [String: [String : String]]
    
    func fetchUserInStore(userToFetch: User, completionHandler: @escaping UserStoreFetchUserCompletionHandler) {
        let url: String = URLManager.fetchUserURL(userId: userToFetch.userId)
        
        NetworkManager.shared.getMethod(url)?
            .decodableResponse(of: UserData.self)
            .subscribe(
                onNext: { [weak self] data in
                    guard let self = self else { return }
                    
                    let user: User? = self.createUser(userId: data.keys.first, userData: data)
                    let result = UserStoreResult<User?>.Success(result: user)
                    completionHandler(result)
                },
                onError: { error in
                    let result = UserStoreResult<User?>.Failure(error: .cannotFetch(error.localizedDescription))
                    completionHandler(result)
                }
            ).disposed(by: self.disposebag)
    }
    
    func createUserInStore(userToCreate: User, completionHandler: @escaping UserStoreCreateUserCompletionHandler) {
        let parameter: UserData = self.createParams(user: userToCreate)
        
        let headers: [HTTPRequestHeaderKey : HTTPRequestHeaderValue] = [
            .contentType : .applicationJson
        ]
        
        let url:String = URLManager.createUserURL()
        
        NetworkManager.shared.patchMethod(url, headers: headers, parameters: parameter, encoding: .json)?
            .decodableResponse(of: UserData.self)
            .subscribe(
                onNext: { [weak self] data in
                    guard let self = self else { return }
                    
                    guard let user = self.createUser(userId: data.keys.first, userData: data) else {
                        let result = UserStoreResult<User>.Failure(error: .cannotCreate("유저를 생성할 수 없습니다"))
                        completionHandler(result)
                        return
                    }
                    
                    let result = UserStoreResult<User>.Success(result: user)
                    completionHandler(result)
                },
                onError: { error in
                    let result = UserStoreResult<User>.Failure(error: .cannotCreate(error.localizedDescription))
                    completionHandler(result)
                }
            ).disposed(by: self.disposebag)
    }
    
    func deleteUserInStore(userToDelete: User, completionHandler: @escaping UserStoreDeleteUserCompletionHandler) {
        
        self.fetchUserInStore(userToFetch: userToDelete) { result in
            switch result {
            case .Success(let userToDelete):
                
                guard let userToDelete = userToDelete else {
                    let result = UserStoreResult<User>.Failure(error: .cannotDelete("유저가 존재하지 않습니다"))
                    completionHandler(result)
                    return
                }
                
                let url: String = URLManager.deleteUserURL(userId: userToDelete.userId)
                
                NetworkManager.shared.deleteMethod(url)?
                    .response()
                    .subscribe(
                        onNext: { _ in
                            let result = UserStoreResult<User>.Success(result: userToDelete)
                            completionHandler(result)
                        },
                        onError: { error in
                            let result = UserStoreResult<User>.Failure(error: .cannotDelete(error.localizedDescription))
                            completionHandler(result)
                        }
                    ).disposed(by: self.disposebag)
                
            case .Failure(let error):
                let result = UserStoreResult<User>.Failure(error: .cannotDelete("\(error)"))
                completionHandler(result)
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
