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
    func appleSignIn(request: CreateUser.AppleSignIn.Request)
    func googleSignIn(request: CreateUser.GoogleSignIn.Request)
    func signIn(request: CreateUser.SignIn.Request)
    func signOut(request: CreateUser.SignOut.Request)
    func signUp(request: CreateUser.SignUp.Request)
    func deleteUser(request: CreateUser.Delete.Request)
}

protocol CreateUserDataStore
{
}

class CreateUserInteractor: CreateUserBusinessLogic, CreateUserDataStore
{
    var presenter: CreateUserPresentationLogic?
    var worker: CreateUserWorker?
    var userWorker = UserWorker(store: UserFirebaseStore(), authentication: FirebaseAuthentication())
    var filtersWorker = FiltersWorker(remoteStore: FilterFirebaseStore(), localStore: FilterMemStore())
    
    // MARK: CreateUserBusinessLogic
    func isSignedIn(request: CreateUser.LoginStatus.Request) {
        
        userWorker.fetchCurrentlyLoggedInUser { [weak self] authResult in
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
    
    func appleSignIn(request: CreateUser.AppleSignIn.Request) {
        guard let presentingViewController = request.presentingViewController else { return }
        
        userWorker.authenticateThroughApple(presentingViewController: presentingViewController) { [weak self] authResult in
            guard let self = self else { return }
            self.signUpProcess(authType: .apple, authResult: authResult)
        }
    }
    
    func googleSignIn(request: CreateUser.GoogleSignIn.Request) {
        guard let presentingViewController = request.presentingViewController else { return }
        
        userWorker.authenticateThroughGoogle(presentingViewController: presentingViewController) { [weak self] authResult in
            guard let self = self else { return }
            self.signUpProcess(authType: .google, authResult: authResult)
        }
    }
    
    func signIn(request: CreateUser.SignIn.Request) {
        let userEmail = request.userEmail
        let userPassword = request.userPassword
        
        userWorker.logIn(email: userEmail, password: userPassword) { [weak self] authResult in
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
        
        userWorker.logOut { [weak self] authResult in
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
        
        userWorker.signUp(email: newEmail, password: newPassword) { [weak self] authResult in
            guard let self = self else { return }
            self.signUpProcess(authType: .email, authResult: authResult)
        }
    }
    
    func deleteUser(request: CreateUser.Delete.Request) {
        userWorker.removeAuthentication { [weak self] authResult in
            guard let self = self else { return }
            
            switch authResult {
            case .Success(let deletedUser):
                self.userWorker.deleteFromDB(deletedUser) { deleteResult in
                    switch deleteResult {
                    case .Success(let deletedUser):
                        self.deleteUserSucceeded(deletedUser: deletedUser)
                    case .Failure(let error):
                        self.deleteUserFailed(error: error)
                    }
                }
            case.Failure(let error):
                self.deleteUserFailed(error: error)
            }
        }
    }
    
    // MARK: - Private methods
    private func deleteUserSucceeded(deletedUser: User) {
        let userResult = CreateUser.UserResult<User>.Success(result: deletedUser)
        presentDeleteResult(deleteResult: userResult)
    }
    
    private func deleteUserFailed(error: Error) {
        let userResult = CreateUser.UserResult<User>.Failure(error: .cannotDelete("\(error)"))
        presentDeleteResult(deleteResult: userResult)
    }
    
    private func presentDeleteResult(deleteResult: CreateUser.UserResult<User>) {
        let response = CreateUser.Delete.Response(deletedUser: deleteResult)
        self.presenter?.presentDeletedUser(response: response)
    }
    
    private func configureInitialFilters(user: User) {
        for filter in FiltersWorker.initialFilters {
            self.filtersWorker.createFilter(user: user, filterToCreate: filter)
        }
    }
    
    enum AuthType {
        case email
        case google
        case apple
    }
    
    private func signUpProcess(authType: AuthType, authResult: UserAuthenticationResult<User>) {
        switch authResult {
        case .Success(let user):
            self.userWorker.findInDB(user) { [weak self] fetchResult in
                guard let self = self else { return }
                
                switch fetchResult {
                case .Success(let fetchedUser):
                    if let fetchedUser = fetchedUser {
                        self.signUpSucceeded(authType: authType, user: fetchedUser)
                    } else {
                        self.userWorker.saveInDB(user) { saveResult in
                            switch saveResult {
                            case .Success(let savedUser):
                                self.configureInitialFilters(user: savedUser)
                                
                                self.signUpSucceeded(authType: authType, user: savedUser)
                            case .Failure(let error):
                                self.userWorker.logOut { _ in
                                    self.signUpFailed(authType: authType, error: error)
                                }
                            }
                        }
                    }
                case .Failure(let error):
                    self.userWorker.logOut { _ in
                        self.signUpFailed(authType: authType, error: error)
                    }
                }
            }
        case .Failure(let error):
            self.signUpFailed(authType: authType, error: error)
        }
    }
    
    private func signUpFailed(authType: AuthType, error: Error) {
        let userResult = CreateUser.UserResult<User>.Failure(error: .cannotSignUp("\(error)"))
        presentSignUpResult(authType: authType, signUpResult: userResult)
    }
    
    private func signUpSucceeded(authType: AuthType, user: User) {
        let userResult = CreateUser.UserResult<User>.Success(result: user)
        presentSignUpResult(authType: authType, signUpResult: userResult)
    }
    
    private func presentSignUpResult(authType: AuthType, signUpResult: CreateUser.UserResult<User>) {
        switch authType {
        case .email:
            let response = CreateUser.SignUp.Response(createdUser: signUpResult)
            self.presenter?.presentSignedUpUser(response: response)
        case .google:
            let response = CreateUser.GoogleSignIn.Response(signedInUser: signUpResult)
            self.presenter?.presentUserSignInWithGoogle(response: response)
        case .apple:
            let response = CreateUser.AppleSignIn.Response(signedInUser: signUpResult)
            self.presenter?.presentUserSignInWithApple(response: response)
        }
    }
}
