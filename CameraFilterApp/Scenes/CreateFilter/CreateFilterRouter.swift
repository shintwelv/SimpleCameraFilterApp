//
//  CreateFilterRouter.swift
//  CameraFilterApp
//
//  Created by ShinIl Heo on 12/2/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

@objc protocol CreateFilterRoutingLogic
{
    func routeToListFilters(segue: UIStoryboardSegue?)
}

protocol CreateFilterDataPassing
{
    var dataStore: CreateFilterDataStore? { get }
}

class CreateFilterRouter: NSObject, CreateFilterRoutingLogic, CreateFilterDataPassing
{
    weak var viewController: CreateFilterViewController?
    var dataStore: CreateFilterDataStore?
    
    // MARK: Routing
    
    func routeToListFilters(segue: UIStoryboardSegue?) {
        self.viewController?.dismiss(animated: true)
    }
}
