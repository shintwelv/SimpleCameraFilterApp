//
//  EditPhotoViewController.swift
//  CameraFilterApp
//
//  Created by siheo on 12/15/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

protocol EditPhotoDisplayLogic: AnyObject
{
    func displayFetchedPhoto(viewModel: EditPhoto.FetchPhoto.ViewModel)
    func displayFetchedFilters(viewModel: EditPhoto.FetchFilters.ViewModel)
    func displayFilterAppliedImage(viewModel: EditPhoto.ApplyFilter.ViewModel)
    func displayPhotoSaveResult(viewModel: EditPhoto.SavePhoto.ViewModel)
}

class EditPhotoViewController: UIViewController, EditPhotoDisplayLogic
{
    var interactor: EditPhotoBusinessLogic?
    var router: (NSObjectProtocol & EditPhotoRoutingLogic & EditPhotoDataPassing)?
    
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
        let interactor = EditPhotoInteractor()
        let presenter = EditPhotoPresenter()
        let router = EditPhotoRouter()
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
    //MARK: - EditPhotoDisplayLogic
    func displayFetchedFilters(viewModel: EditPhoto.FetchFilters.ViewModel) {}
    func displayFilterAppliedImage(viewModel: EditPhoto.ApplyFilter.ViewModel) {}
    func displayPhotoSaveResult(viewModel: EditPhoto.SavePhoto.ViewModel) {}
    func displayPhotoSaveResult(viewModel: EditPhoto.SavePhoto.ViewModel) {
    }
}
