//
//  EditPhotoInteractor.swift
//  CameraFilterApp
//
//  Created by siheo on 12/15/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

protocol EditPhotoBusinessLogic
{
  func doSomething(request: EditPhoto.Something.Request)
}

protocol EditPhotoDataStore
{
  //var name: String { get set }
}

class EditPhotoInteractor: EditPhotoBusinessLogic, EditPhotoDataStore
{
  var presenter: EditPhotoPresentationLogic?
  var worker: EditPhotoWorker?
  //var name: String = ""
  
  // MARK: Do something
  
  func doSomething(request: EditPhoto.Something.Request)
  {
    worker = EditPhotoWorker()
    worker?.doSomeWork()
    
    let response = EditPhoto.Something.Response()
    presenter?.presentSomething(response: response)
  }
}
