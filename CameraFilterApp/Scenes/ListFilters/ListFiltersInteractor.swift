//
//  ListFiltersInteractor.swift
//  CameraFilterApp
//
//  Created by siheo on 11/30/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

protocol ListFiltersBusinessLogic
{
    func fetchFilters(request: ListFilters.FetchFilters.Request)
}

protocol ListFiltersDataStore
{
  //var name: String { get set }
}

class ListFiltersInteractor: ListFiltersBusinessLogic, ListFiltersDataStore
{
    var presenter: ListFiltersPresentationLogic?
    var filtersWorker: FiltersWorker = FiltersWorker(filtersStore: FilterMemStore())
    
    // MARK: Fetch filters
    func fetchFilters(request: ListFilters.FetchFilters.Request) {
        filtersWorker.fetchFilters { filters in
            let response = ListFilters.FetchFilters.Response(filters: filters)
            self.presenter?.displayFilters(response: response)
        }
    }
}
