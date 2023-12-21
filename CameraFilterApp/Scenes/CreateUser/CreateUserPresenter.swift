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
    func presentUserSignInWithGoogle(response: CreateUser.GoogleSignIn.Response)
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
                self.viewController?.displayLoginStatus(viewModel: viewModel)
            } else {
                let viewModel = CreateUser.LoginStatus.ViewModel(signedInUserEmail: nil)
                self.viewController?.displayLoginStatus(viewModel: viewModel)
            }
        case .Failure(_):
            let viewModel = CreateUser.LoginStatus.ViewModel(signedInUserEmail: nil)
            self.viewController?.displayLoginStatus(viewModel: viewModel)
        }
    }
    
    func presentUserSignInWithGoogle(response: CreateUser.GoogleSignIn.Response) {
        let signedInUser = response.signedInUser
        
        switch signedInUser {
        case .Success(let user):
            let viewModel = CreateUser.GoogleSignIn.ViewModel(signedInUserEmail: user.email)
            self.viewController?.displayUserSignedInWithGoogle(viewModel: viewModel)
        case .Failure(_):
            let viewModel = CreateUser.GoogleSignIn.ViewModel(signedInUserEmail: nil)
            self.viewController?.displayUserSignedInWithGoogle(viewModel: viewModel)
        }
    }
    
    func presentSignedInUser(response: CreateUser.SignIn.Response) {
        let signedInUser = response.signedInUser
        
        switch signedInUser {
        case .Success(let user):
            let viewModel = CreateUser.SignIn.ViewModel(signedInUserEmail: user.email)
            self.viewController?.displaySignedInUser(viewModel: viewModel)
        case .Failure(_):
            let viewModel = CreateUser.SignIn.ViewModel(signedInUserEmail: nil)
            self.viewController?.displaySignedInUser(viewModel: viewModel)
        }
    }
    
    func presentSignedOutUser(response: CreateUser.SignOut.Response) {
        let signedOutUser = response.signedOutUser
        
        switch signedOutUser {
        case .Success(let user):
            let viewModel = CreateUser.SignOut.ViewModel(signedOutUserEmail: user.email)
            self.viewController?.displaySignedOutUser(viewModel: viewModel)
        case .Failure(_):
            let viewModel = CreateUser.SignOut.ViewModel(signedOutUserEmail: nil)
            self.viewController?.displaySignedOutUser(viewModel: viewModel)
        }
    }
    
    func presentSignedUpUser(response: CreateUser.SignUp.Response) {
        let createdUser = response.createdUser
        
        switch createdUser {
        case .Success(let user):
            let viewModel = CreateUser.SignUp.ViewModel(createdUserEmail: user.email)
            self.viewController?.displaySignedUpUser(viewModel: viewModel)
        case .Failure(_):
            let viewModel = CreateUser.SignUp.ViewModel(createdUserEmail: nil)
            self.viewController?.displaySignedUpUser(viewModel: viewModel)
        }
    }
}
