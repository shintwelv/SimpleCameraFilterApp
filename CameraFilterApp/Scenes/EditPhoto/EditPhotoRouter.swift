//
//  EditPhotoRouter.swift
//  CameraFilterApp
//
//  Created by siheo on 12/15/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

@objc protocol EditPhotoRoutingLogic
{
    func routeToCameraPreview(segue: UIStoryboardSegue?)
    func routeToListFilters(segue: UIStoryboardSegue?)
}

protocol EditPhotoDataPassing
{
    var dataStore: EditPhotoDataStore? { get }
}

class EditPhotoRouter: NSObject, EditPhotoRoutingLogic, EditPhotoDataPassing
{
    weak var viewController: EditPhotoViewController?
    var dataStore: EditPhotoDataStore?
    
    // MARK: Routing
    
    func routeToCameraPreview(segue: UIStoryboardSegue?) {
        if let segue = segue {
            guard let dstVC = segue.destination as? CameraPreviewViewController,
                    var dstDS = dstVC.router?.dataStore else { return }
            
            passDataToCameraPreview(source: dataStore!, destination: &dstDS)
            navigateToCameraPreview(source: viewController!, destination: dstVC)
        } else {
            let dstVC = CameraPreviewViewController()
            guard var dstDS = dstVC.router?.dataStore else { return }
            
            passDataToCameraPreview(source: dataStore!, destination: &dstDS)
            navigateToCameraPreview(source: viewController!, destination: dstVC)
        }
    }
    
    func routeToListFilters(segue: UIStoryboardSegue?) {
        if let segue = segue {
            guard let dstVC = segue.destination as? ListFiltersViewController,
                    var dstDS = dstVC.router?.dataStore else { return }
            
            passDataToListFilters(source: dataStore!, destination: &dstDS)
            navigateToListFilters(source: viewController!, destination: dstVC)
        } else {
            let dstVC = ListFiltersViewController()
            guard var dstDS = dstVC.router?.dataStore else { return }
            
            passDataToListFilters(source: dataStore!, destination: &dstDS)
            navigateToListFilters(source: viewController!, destination: dstVC)
        }
    }
    
    // MARK: Navigation
    
    func navigateToCameraPreview(source: EditPhotoViewController, destination: CameraPreviewViewController) {
        source.dismiss(animated: true)
    }
    
    func navigateToListFilters(source: EditPhotoViewController, destination: ListFiltersViewController) {
        source.present(destination, animated: true)
    }
    
    // MARK: Passing data
    
    func passDataToCameraPreview(source: EditPhotoDataStore, destination: inout CameraPreviewDataStore) {
    }
    
    func passDataToListFilters(source: EditPhotoDataStore, destination: inout ListFiltersDataStore) {
    }
}
