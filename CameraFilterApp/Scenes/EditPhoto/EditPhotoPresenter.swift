//
//  EditPhotoPresenter.swift
//  CameraFilterApp
//
//  Created by siheo on 12/15/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

protocol EditPhotoPresentationLogic
{
  func presentSomething(response: EditPhoto.Something.Response)
}

class EditPhotoPresenter: EditPhotoPresentationLogic
{
  weak var viewController: EditPhotoDisplayLogic?
  
  // MARK: Do something
  
  func presentSomething(response: EditPhoto.Something.Response)
  {
    let viewModel = EditPhoto.Something.ViewModel()
    viewController?.displaySomething(viewModel: viewModel)
  }
}
