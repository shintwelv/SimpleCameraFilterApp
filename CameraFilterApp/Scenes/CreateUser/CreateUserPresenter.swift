//
//  CreateUserPresenter.swift
//  CameraFilterApp
//
//  Created by siheo on 12/18/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

protocol CreateUserPresentationLogic
{
    func presentLoginStatus(response: CreateUser.LoginStatus.Response)
    func presentSignedInUser(response: CreateUser.SignIn.Response)
    func presentSignedOutUser(response: CreateUser.SignOut.Response)
    func presentSignedUpUser(response: CreateUser.SignUp.Response)
}

class CreateUserPresenter: CreateUserPresentationLogic
{
  weak var viewController: CreateUserDisplayLogic?
  
  // MARK: CreateUserPresentationLogic
    func presentLoginStatus(response: CreateUser.LoginStatus.Response) {
        let signedInUser = response.signedInUser

        switch signedInUser {
        case .Success(let user):
            if let user = user {
                let viewModel = CreateUser.LoginStatus.ViewModel(signedInUserEmail: user.email)
            } else {
                let viewModel = CreateUser.LoginStatus.ViewModel(signedInUserEmail: nil)
            }
        case .Failure(let error):
            let viewModel = CreateUser.LoginStatus.ViewModel(signedInUserEmail: nil)
        }
    }
    
    func presentSignedInUser(response: CreateUser.SignIn.Response) {
        let signedInUser = response.signedInUser
        
        switch signedInUser {
        case .Success(let user):
            let viewModel = CreateUser.SignIn.ViewModel(signedInUserEmail: user.email)
        case .Failure(let error):
            let viewModel = CreateUser.SignIn.ViewModel(signedInUserEmail: nil)
        }
    }
    
    func presentSignedOutUser(response: CreateUser.SignOut.Response) {
        let signedOutUser = response.signedOutUser
        
        switch signedOutUser {
        case .Success(let user):
            let viewModel = CreateUser.SignOut.ViewModel(signedOutUserEmail: user.email)
        case .Failure(let error):
            let viewModel = CreateUser.SignOut.ViewModel(signedOutUserEmail: nil)
        }
    }
    
    func presentSignedUpUser(response: CreateUser.SignUp.Response) {
        let createdUser = response.createdUser
        
        switch createdUser {
        case .Success(let user):
            let viewModel = CreateUser.SignUp.ViewModel(createdUserEmail: user.email)
        case .Failure(let error):
            let viewModel = CreateUser.SignUp.ViewModel(createdUserEmail: nil)
        }
    }
}
