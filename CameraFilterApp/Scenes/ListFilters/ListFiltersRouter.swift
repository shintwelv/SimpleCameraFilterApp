//
//  ListFiltersRouter.swift
//  CameraFilterApp
//
//  Created by siheo on 11/30/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

@objc protocol ListFiltersRoutingLogic
{
  //func routeToSomewhere(segue: UIStoryboardSegue?)
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
  
  //func routeToSomewhere(segue: UIStoryboardSegue?)
  //{
  //  if let segue = segue {
  //    let destinationVC = segue.destination as! SomewhereViewController
  //    var destinationDS = destinationVC.router!.dataStore!
  //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
  //  } else {
  //    let storyboard = UIStoryboard(name: "Main", bundle: nil)
  //    let destinationVC = storyboard.instantiateViewController(withIdentifier: "SomewhereViewController") as! SomewhereViewController
  //    var destinationDS = destinationVC.router!.dataStore!
  //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
  //    navigateToSomewhere(source: viewController!, destination: destinationVC)
  //  }
  //}

  // MARK: Navigation
  
  //func navigateToSomewhere(source: ListFiltersViewController, destination: SomewhereViewController)
  //{
  //  source.show(destination, sender: nil)
  //}
  
  // MARK: Passing data
  
  //func passDataToSomewhere(source: ListFiltersDataStore, destination: inout SomewhereDataStore)
  //{
  //  destination.name = source.name
  //}
}
