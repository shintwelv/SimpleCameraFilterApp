//
//  ListFiltersRouter.swift
//  CameraFilterApp
//
//  Created by siheo on 11/30/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

@objc protocol ListFiltersRoutingLogic
{
    func routeToCreateFilter(segue: UIStoryboardSegue?)
}

protocol ListFiltersDataPassing
{
    var dataStore: ListFiltersDataStore? { get }
}

class ListFiltersRouter: NSObject, ListFiltersRoutingLogic, ListFiltersDataPassing
{
    weak var viewController: ListFiltersViewController?
    var dataStore: ListFiltersDataStore?
    
    // MARK: Routing
    
    func routeToCreateFilter(segue: UIStoryboardSegue?) {
        guard let dataStore = self.dataStore,
              let viewController = self.viewController else { return }
        
        if let segue = segue {
            guard let dstVC = segue.destination as? CreateFilterViewController,
                  var dstDS = dstVC.router?.dataStore else { return }
            
            passDataToCreateFilter(source: dataStore, destination: &dstDS)
            navigateToCreateFilter(source: viewController, destination: dstVC)
        } else {
            let dstVC = CreateFilterViewController()
            
            guard var dstDS = dstVC.router?.dataStore else { return }
            
            passDataToCreateFilter(source: dataStore, destination: &dstDS)
            navigateToCreateFilter(source: viewController, destination: dstVC)
        }
    }
    
    // MARK: Navigation
    
    func navigateToCreateFilter(source: ListFiltersViewController, destination: CreateFilterViewController) {
        source.show(destination, sender: nil)
    }
    
    // MARK: Passing data
    
    func passDataToCreateFilter(source: ListFiltersDataStore, destination: inout CreateFilterDataStore) {
        destination.filterId = source.selectedFilterId
    }
}
