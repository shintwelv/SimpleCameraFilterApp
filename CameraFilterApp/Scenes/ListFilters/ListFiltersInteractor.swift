//
//  ListFiltersInteractor.swift
//  CameraFilterApp
//
//  Created by siheo on 11/30/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

protocol ListFiltersBusinessLogic
{
}

protocol ListFiltersDataStore
{
  //var name: String { get set }
}

class ListFiltersInteractor: ListFiltersBusinessLogic, ListFiltersDataStore
{
  var presenter: ListFiltersPresentationLogic?
  var worker: ListFiltersWorker?
  //var name: String = ""
  
  // MARK: Do something
}
