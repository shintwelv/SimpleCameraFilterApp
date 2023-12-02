//
//  CreateFilterInteractor.swift
//  CameraFilterApp
//
//  Created by ShinIl Heo on 12/2/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

protocol CreateFilterBusinessLogic
{
}

protocol CreateFilterDataStore
{
  //var name: String { get set }
}

class CreateFilterInteractor: CreateFilterBusinessLogic, CreateFilterDataStore
{
  var presenter: CreateFilterPresentationLogic?
  var worker: CreateFilterWorker?
  //var name: String = ""
  
  // MARK: Do something
}
