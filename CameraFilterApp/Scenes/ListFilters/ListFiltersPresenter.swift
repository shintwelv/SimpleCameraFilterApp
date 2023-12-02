//
//  ListFiltersPresenter.swift
//  CameraFilterApp
//
//  Created by siheo on 11/30/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

protocol ListFiltersPresentationLogic
{
    func displayFilters(response: ListFilters.FetchFilters.Response)
}

class ListFiltersPresenter: ListFiltersPresentationLogic
{
    weak var viewController: ListFiltersDisplayLogic?
    
    func displayFilters(response: ListFilters.FetchFilters.Response) {
    }
}
