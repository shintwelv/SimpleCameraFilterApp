//
//  CreateUserRouter.swift
//  CameraFilterApp
//
//  Created by siheo on 12/18/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

@objc protocol CreateUserRoutingLogic
{
    func routeToCameraPreview(segue: UIStoryboardSegue?)
}

protocol CreateUserDataPassing
{
    var dataStore: CreateUserDataStore? { get }
}

class CreateUserRouter: NSObject, CreateUserRoutingLogic, CreateUserDataPassing
{
    weak var viewController: CreateUserViewController?
    var dataStore: CreateUserDataStore?
    
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
    
    // MARK: Navigation
    func navigateToCameraPreview(source: CreateUserViewController, destination: CameraPreviewViewController) {
        source.dismiss(animated: true)
    }
    
    // MARK: Passing data
    func passDataToCameraPreview(source: CreateUserDataStore, destination: inout CameraPreviewDataStore) {
    }
}
