//
//  UserFirebaseStore.swift
//  CameraFilterApp
//
//  Created by siheo on 1/3/24.
//

import Foundation
import NetworkManager
import Alamofire

class UserFirebaseStore: UserStoreProtocol {
    
    enum ParamKey:String {
        case email
    }
    
    static let endPoint: String = FirebaseDB.Endpoint.url.rawValue + "/" + FirebaseDB.Name.users.rawValue
    
    typealias UserData = [String: [String : String]]
    
    func fetchUserInStore(userToFetch: User, completionHandler: @escaping UserStoreFetchUserCompletionHandler) {
        let url: String = "\(UserFirebaseStore.endPoint).\(FirebaseDB.FileExt.json)?\(FirebaseDB.OrderBy.key)&\(FirebaseDB.Filtering.equalTo(param: userToFetch.userId))"
        
        NetworkManager.shared.getMethod(url)?.decodableResponse(of: UserData.self, completionHandler: { [weak self] (response: HTTPResponse<UserData>) in
            
            guard let self = self else { return }
            
            switch response {
            case .Success(let data):
                let user: User? = self.createUser(userId: data.keys.first, userData: data)
                let result = UserStoreResult<User?>.Success(result: user)
                completionHandler(result)
            case .Fail(let error):
                let result = UserStoreResult<User?>.Failure(error: .cannotFetch(error.localizedDescription))
                completionHandler(result)
            }
        })
    }
    
    func createUserInStore(userToCreate: User, completionHandler: @escaping UserStoreCreateUserCompletionHandler) {
        let parameter: UserData = self.createParams(user: userToCreate)
        
        let headers: [String : String] = [
            "Content-Type": FirebaseDB.ContentType.applicationJson.rawValue
        ]
        
        let url:String = "\(UserFirebaseStore.endPoint).\(FirebaseDB.FileExt.json)"
        
        NetworkManager.shared.patchMethod(url, headers: headers, parameters: parameter, encoding: .json)?.decodableResponse(of: UserData.self, completionHandler: { [weak self] (response: HTTPResponse<UserData>) in
            guard let self = self else { return }
            
            switch response {
            case .Success(let data):
                guard let user = self.createUser(userId: data.keys.first, userData: data) else {
                    let result = UserStoreResult<User>.Failure(error: .cannotCreate("유저를 생성할 수 없습니다"))
                    completionHandler(result)
                    return
                }
                
                let result = UserStoreResult<User>.Success(result: user)
                completionHandler(result)
            case .Fail(let error):
                let result = UserStoreResult<User>.Failure(error: .cannotCreate(error.localizedDescription))
                completionHandler(result)
            }
        })
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
                
                let url: String = "\(UserFirebaseStore.endPoint)/\(userToDelete.userId).\(FirebaseDB.FileExt.json)"
                
                NetworkManager.shared.deleteMethod(url)?.response(completionHandler: { (response: HTTPResponse<Data?>) in
                    switch response {
                    case .Success(_):
                        let result = UserStoreResult<User>.Success(result: userToDelete)
                        completionHandler(result)
                    case .Fail(let error):
                        let result = UserStoreResult<User>.Failure(error: .cannotDelete(error.localizedDescription))
                        completionHandler(result)
                    }
                })
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
