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
        
        authenticateProvider.loggedInUser { authResult in
            switch authResult {
            case .Success(let user):
                let userResult = CreateUser.UserResult.Success(result: user)
                let response = CreateUser.LoginStatus.Response(signedInUser: userResult)
            case .Failure(let error):
                let userResult = CreateUser.UserResult<User?>.Failure(error: .cannotCheckLogin("\(error)"))
                let response = CreateUser.LoginStatus.Response(signedInUser: userResult)
            }
        }
    }
    
    func signIn(request: CreateUser.SignIn.Request) {
        let userEmail = request.userEmail
        let userPassword = request.userPassword
        
        authenticateProvider.login(email: userEmail, password: userPassword) { authResult in
            switch authResult {
            case .Success(let user):
                let userResult = CreateUser.UserResult<User>.Success(result: user)
                let response = CreateUser.SignIn.Response(signedInUser: userResult)
            case .Failure(let error):
                let userResult = CreateUser.UserResult<User>.Failure(error:.cannotSignIn("\(error)"))
                let response = CreateUser.SignIn.Response(signedInUser: userResult)
            }
        }
    }
    
    func signOut(request: CreateUser.SignOut.Request) {
        
        authenticateProvider.logOut { authResult in
            switch authResult {
            case .Success(let user):
                let userResult = CreateUser.UserResult<User>.Success(result: user)
                let response = CreateUser.SignOut.Response(signedOutUser: userResult)
            case .Failure(let error):
                let userResult = CreateUser.UserResult<User>.Failure(error: .cannotSignOut("\(error)"))
                let response = CreateUser.SignOut.Response(signedOutUser: userResult)
            }
        }
    }
    
    func signUp(request: CreateUser.SignUp.Request) {
        let newEmail = request.newEmail
        let newPassword = request.newPassword
        
        authenticateProvider.signUp(email: newEmail, password: newPassword) { authResult in
            switch authResult {
            case .Success(let createUser):
                let userResult = CreateUser.UserResult<User>.Success(result: createUser)
                let response = CreateUser.SignUp.Response(createdUser: userResult)
            case .Failure(let error):
                let userResult = CreateUser.UserResult<User>.Failure(error: .cannotSignUp("\(error)"))
                let response = CreateUser.SignUp.Response(createdUser: userResult)
            }
        }
    }
}
