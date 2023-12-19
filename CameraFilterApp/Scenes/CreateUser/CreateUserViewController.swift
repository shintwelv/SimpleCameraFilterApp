//
//  CreateUserViewController.swift
//  CameraFilterApp
//
//  Created by siheo on 12/18/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

protocol CreateUserDisplayLogic: AnyObject
{
    func displayLoginStatus(viewModel: CreateUser.LoginStatus.ViewModel)
    func displaySignedInUser(viewModel: CreateUser.SignIn.ViewModel)
    func displaySignedOutUser(viewModel: CreateUser.SignOut.ViewModel)
    func displaySignedUpUser(viewModel: CreateUser.SignUp.ViewModel)
}

class CreateUserViewController: UIViewController, CreateUserDisplayLogic
{
    var interactor: CreateUserBusinessLogic?
    var router: (NSObjectProtocol & CreateUserRoutingLogic & CreateUserDataPassing)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = CreateUserInteractor()
        let presenter = CreateUserPresenter()
        let router = CreateUserRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    // MARK: - CreateUserBusinessLogic
    
    // MARK: CreateUserDisplayLogic
    func displayLoginStatus(viewModel: CreateUser.LoginStatus.ViewModel) {
    }
    
    func displaySignedInUser(viewModel: CreateUser.SignIn.ViewModel) {
    }
    
    func displaySignedOutUser(viewModel: CreateUser.SignOut.ViewModel) {
    }
    
    func displaySignedUpUser(viewModel: CreateUser.SignUp.ViewModel) {
    }
}
