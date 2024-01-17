//
//  CreateUserInteractor.swift
//  CameraFilterApp
//
//  Created by siheo on 12/18/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit
import RxSwift

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
    
    private var bag = DisposeBag()

    // MARK: CreateUserBusinessLogic
    func isSignedIn(request: CreateUser.LoginStatus.Request) {
        userWorker.fetchCurrentlyLoggedInUser()
            .subscribe(
                onNext: { [weak self] user in
                    guard let self = self else { return }
                    
                    let userResult = CreateUser.UserResult.Success(result: user)
                    let response = CreateUser.LoginStatus.Response(signedInUser: userResult)
                    self.presenter?.presentLoginStatus(response: response)
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    
                    let userResult = CreateUser.UserResult<User?>.Failure(error: .cannotCheckLogin("\(error)"))
                    let response = CreateUser.LoginStatus.Response(signedInUser: userResult)
                    self.presenter?.presentLoginStatus(response: response)
                }
            ).disposed(by: self.bag)
    }
    
    func appleSignIn(request: CreateUser.AppleSignIn.Request) {
        guard let presentingViewController = request.presentingViewController else { return }
        
        let observable = userWorker.authenticateThroughApple(presentingViewController: presentingViewController)
        signUpProcess(authType: .apple, observable: observable)
    }
    
    func googleSignIn(request: CreateUser.GoogleSignIn.Request) {
        guard let presentingViewController = request.presentingViewController else { return }
        
        let observable = userWorker.authenticateThroughGoogle(presentingViewController: presentingViewController)
        signUpProcess(authType: .google, observable: observable)
    }
    
    func signIn(request: CreateUser.SignIn.Request) {
        let userEmail = request.userEmail
        let userPassword = request.userPassword
        
        userWorker.logIn(email: userEmail, password: userPassword)
            .subscribe(
                onNext: { [weak self] user in
                    guard let self = self else { return }
                    
                    let userResult = CreateUser.UserResult<User>.Success(result: user)
                    let response = CreateUser.SignIn.Response(signedInUser: userResult)
                    self.presenter?.presentSignedInUser(response: response)
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    
                    let userResult = CreateUser.UserResult<User>.Failure(error:.cannotSignIn("\(error)"))
                    let response = CreateUser.SignIn.Response(signedInUser: userResult)
                    self.presenter?.presentSignedInUser(response: response)
                }
            )
            .disposed(by: self.bag)
    }
    
    func signOut(request: CreateUser.SignOut.Request) {
        
        userWorker.logOut()
            .subscribe(
                onNext: { [weak self] user in
                    guard let self = self else { return }
                    
                    let userResult = CreateUser.UserResult<User>.Success(result: user)
                    let response = CreateUser.SignOut.Response(signedOutUser: userResult)
                    self.presenter?.presentSignedOutUser(response: response)
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    
                    let userResult = CreateUser.UserResult<User>.Failure(error: .cannotSignOut("\(error)"))
                    let response = CreateUser.SignOut.Response(signedOutUser: userResult)
                    self.presenter?.presentSignedOutUser(response: response)
                }
            )
            .disposed(by: self.bag)
    }
    
    func signUp(request: CreateUser.SignUp.Request) {
        let newEmail = request.newEmail
        let newPassword = request.newPassword
        
        let observable = userWorker.signUp(email: newEmail, password: newPassword)
        signUpProcess(authType: .email, observable: observable)
    }
    
    func deleteUser(request: CreateUser.Delete.Request) {
        userWorker.removeAuthentication()
            .subscribe(
                onNext: { [weak self] user in
                    guard let self = self else { return }
                    
                    self.userWorker.deleteFromDB(user)
                        .subscribe(
                            onNext: { deletedUser in
                                self.deleteUserSucceeded(deletedUser: deletedUser)
                            },
                            onError: { error in
                                self.deleteUserFailed(error: error)
                            }
                        )
                        .disposed(by: self.bag)
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    
                    self.deleteUserFailed(error: error)
                }
            )
            .disposed(by: self.bag)
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
                .subscribe()
                .disposed(by: self.bag)
        }
    }
    
    enum AuthType {
        case email
        case google
        case apple
    }
    
    private func signUpProcess(authType: AuthType, observable: Observable<User>) {
        observable.subscribe(
            onNext: { [weak self] user in
                guard let self = self else { return }
                
                self.userWorker.findInDB(user)
                    .subscribe(
                        onNext: { fetchedUser in
                            if let fetchedUser = fetchedUser {
                                self.signUpSucceeded(authType: authType, user: fetchedUser)
                            } else {
                                self.saveUser(authType: authType, user: user)
                            }
                        },
                        onError: { error in
                            self.cancelLogin(authType: authType, error: error)
                        }
                    )
                    .disposed(by: self.bag)
            },
            onError: { [weak self] error in
                guard let self = self else { return }
                
                self.signUpFailed(authType: authType, error: error)
            }
        )
        .disposed(by: self.bag)
    }
    
    private func cancelLogin(authType: AuthType, error: Error) {
        self.userWorker.logOut()
            .subscribe(
                onNext: { _ in
                    self.signUpFailed(authType: authType, error: error)
                },
                onError: { _ in
                    self.signUpFailed(authType: authType, error: error)
                }
            )
            .disposed(by: self.bag)
    }
    
    private func saveUser(authType: AuthType, user: User) {
        self.userWorker.saveInDB(user)
            .subscribe(
                onNext: { [weak self] savedUser in
                    guard let self = self else { return }
                    
                    self.configureInitialFilters(user: savedUser)
                    self.signUpSucceeded(authType: authType, user: savedUser)
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    
                    self.cancelLogin(authType: authType, error: error)
                }
            )
            .disposed(by: self.bag)
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
