//
//  UserFirebaseStore.swift
//  CameraFilterApp
//
//  Created by siheo on 1/3/24.
//

import Foundation
import Alamofire

class UserFirebaseStore: UserStoreProtocol {
    
    enum ParamKey:String {
        case email
    }
    
    static let endPoint: String = FirebaseDB.Endpoint.url.rawValue + "/" + FirebaseDB.Name.users.rawValue
    
    typealias UserData = [String: [String : String]]
    
    func fetchUserInStore(userToFetch: User, completionHandler: @escaping UserStoreFetchUserCompletionHandler) {
        AF.request("\(UserFirebaseStore.endPoint).\(FirebaseDB.FileExt.json)?\(FirebaseDB.OrderBy.key)&\(FirebaseDB.Filtering.equalTo(param: userToFetch.userId))")
            .responseDecodable(of:UserData.self) { [weak self] response in
                
                guard let self = self else { return }
                
                guard let responseValue = response.value else {
                    let result = UserStoreResult<User?>.Failure(error: .cannotFetch("서버로부터 데이터를 받아올 수 없습니다"))
                    completionHandler(result)
                    return
                }
                
                let user: User? = self.createUser(userId: responseValue.keys.first, userData: responseValue)
                let result = UserStoreResult<User?>.Success(result: user)
                completionHandler(result)
            }
    }
    
    func createUserInStore(userToCreate: User, completionHandler: @escaping UserStoreCreateUserCompletionHandler) {
        let parameter: UserData = self.createParams(user: userToCreate)
        
        let headers: HTTPHeaders = [
            .contentType(FirebaseDB.ContentType.applicationJson.rawValue)
        ]
        
        AF.request("\(UserFirebaseStore.endPoint).\(FirebaseDB.FileExt.json)", method: .patch, parameters: parameter, encoder: JSONParameterEncoder.default, headers: headers)
            .responseDecodable(of:UserData.self) { [weak self] response in
                
                guard let self = self else { return }
                
                guard let responseValue = response.value else {
                    let result = UserStoreResult<User>.Failure(error: .cannotCreate("서버로부터 데이터를 받아올 수 없습니다"))
                    completionHandler(result)
                    return
                }
                
                guard let user = self.createUser(userId: responseValue.keys.first, userData: responseValue) else {
                    let result = UserStoreResult<User>.Failure(error: .cannotCreate("유저를 생성할 수 없습니다"))
                    completionHandler(result)
                    return
                }
                
                let result = UserStoreResult<User>.Success(result: user)
                completionHandler(result)
            }
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
                
                AF.request("\(UserFirebaseStore.endPoint)/\(userToDelete.userId).\(FirebaseDB.FileExt.json)", method: .delete)
                    .responseDecodable(of:UserData.self) { response in
                        
                        guard let statusCode = response.response?.statusCode, (200..<300).contains(statusCode) else {
                            let result = UserStoreResult<User>.Failure(error: .cannotDelete("서버로부터 데이터를 받아올 수 없습니다"))
                            completionHandler(result)
                            return
                        }
                        
                        let result = UserStoreResult<User>.Success(result: userToDelete)
                        completionHandler(result)
                    }
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
