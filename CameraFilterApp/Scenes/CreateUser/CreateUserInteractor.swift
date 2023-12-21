//
//  CreateUserInteractor.swift
//  CameraFilterApp
//
//  Created by siheo on 12/18/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

protocol CreateUserBusinessLogic
{
    func isSignedIn(request: CreateUser.LoginStatus.Request)
    func googleSignIn(request: CreateUser.GoogleSignIn.Request)
    func signIn(request: CreateUser.SignIn.Request)
    func signOut(request: CreateUser.SignOut.Request)
    func signUp(request: CreateUser.SignUp.Request)
}

protocol CreateUserDataStore
{
}

class CreateUserInteractor: CreateUserBusinessLogic, CreateUserDataStore
{
    var presenter: CreateUserPresentationLogic?
    var worker: CreateUserWorker?
    var authenticateProvider = UserAuthenticationWorker(provider: FirebaseAuthentication())
    
    // MARK: CreateUserBusinessLogic
    func isSignedIn(request: CreateUser.LoginStatus.Request) {
        
        authenticateProvider.loggedInUser { [weak self] authResult in
            guard let self = self else { return }
            
            switch authResult {
            case .Success(let user):
                let userResult = CreateUser.UserResult.Success(result: user)
                let response = CreateUser.LoginStatus.Response(signedInUser: userResult)
                self.presenter?.presentLoginStatus(response: response)
            case .Failure(let error):
                let userResult = CreateUser.UserResult<User?>.Failure(error: .cannotCheckLogin("\(error)"))
                let response = CreateUser.LoginStatus.Response(signedInUser: userResult)
                self.presenter?.presentLoginStatus(response: response)
            }
        }
    }
    
    func googleSignIn(request: CreateUser.GoogleSignIn.Request) {
        guard let presentingViewController = request.presentingViewController else { return }
        
        authenticateProvider.googleLogin(presentingViewController: presentingViewController) { [weak self] authResult in
            guard let self = self else { return }
            
            switch authResult {
            case .Success(let user):
                let userResult = CreateUser.UserResult<User>.Success(result: user)
                let response = CreateUser.GoogleSignIn.Response(signedInUser: userResult)
                self.presenter?.presentUserSignInWithGoogle(response: response)
            case .Failure(let error):
                let userResult = CreateUser.UserResult<User>.Failure(error:.cannotSignIn("\(error)"))
                let response = CreateUser.GoogleSignIn.Response(signedInUser: userResult)
                self.presenter?.presentUserSignInWithGoogle(response: response)
            }
        }
    }
    
    func signIn(request: CreateUser.SignIn.Request) {
        let userEmail = request.userEmail
        let userPassword = request.userPassword
        
        authenticateProvider.login(email: userEmail, password: userPassword) { [weak self] authResult in
            guard let self = self else { return }
            
            switch authResult {
            case .Success(let user):
                let userResult = CreateUser.UserResult<User>.Success(result: user)
                let response = CreateUser.SignIn.Response(signedInUser: userResult)
                self.presenter?.presentSignedInUser(response: response)
            case .Failure(let error):
                let userResult = CreateUser.UserResult<User>.Failure(error:.cannotSignIn("\(error)"))
                let response = CreateUser.SignIn.Response(signedInUser: userResult)
                self.presenter?.presentSignedInUser(response: response)
            }
        }
    }
    
    func signOut(request: CreateUser.SignOut.Request) {
        
        authenticateProvider.logOut { [weak self] authResult in
            guard let self = self else { return }
            
            switch authResult {
            case .Success(let user):
                let userResult = CreateUser.UserResult<User>.Success(result: user)
                let response = CreateUser.SignOut.Response(signedOutUser: userResult)
                self.presenter?.presentSignedOutUser(response: response)
            case .Failure(let error):
                let userResult = CreateUser.UserResult<User>.Failure(error: .cannotSignOut("\(error)"))
                let response = CreateUser.SignOut.Response(signedOutUser: userResult)
                self.presenter?.presentSignedOutUser(response: response)
            }
        }
    }
    
    func signUp(request: CreateUser.SignUp.Request) {
        let newEmail = request.newEmail
        let newPassword = request.newPassword
        
        authenticateProvider.signUp(email: newEmail, password: newPassword) { [weak self] authResult in
            guard let self = self else { return }
            
            switch authResult {
            case .Success(let createUser):
                let userResult = CreateUser.UserResult<User>.Success(result: createUser)
                let response = CreateUser.SignUp.Response(createdUser: userResult)
                self.presenter?.presentSignedUpUser(response: response)
            case .Failure(let error):
                let userResult = CreateUser.UserResult<User>.Failure(error: .cannotSignUp("\(error)"))
                let response = CreateUser.SignUp.Response(createdUser: userResult)
                self.presenter?.presentSignedUpUser(response: response)
            }
        }
    }
}
