//
//  CreateUserInteractor.swift
//  CameraFilterApp
//
//  Created by siheo on 12/18/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

protocol CreateUserBusinessLogic
{
}

protocol CreateUserDataStore
{
}

class CreateUserInteractor: CreateUserBusinessLogic, CreateUserDataStore
{
    var presenter: CreateUserPresentationLogic?
    var worker: CreateUserWorker?
    
    // MARK: CreateUserBusinessLogic
}
