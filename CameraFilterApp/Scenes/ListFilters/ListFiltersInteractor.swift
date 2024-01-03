//
//  ListFiltersInteractor.swift
//  CameraFilterApp
//
//  Created by siheo on 11/30/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit
import RxSwift

protocol ListFiltersBusinessLogic
{
    func fetchFilters(request: ListFilters.FetchFilters.Request)
    func selectFilter(request: ListFilters.SelectFilter.Request)
}

protocol ListFiltersDataStore
{
    var selectedFilterId: UUID? { get }
}

class ListFiltersInteractor: ListFiltersBusinessLogic, ListFiltersDataStore
{
    var presenter: ListFiltersPresentationLogic?
    var filtersWorker: FiltersWorker = FiltersWorker(remoteStore: FilterFirebaseStore(), localStore: FilterMemStore())
    var authenticationWorker: UserAuthenticationWorker = UserAuthenticationWorker(provider: FirebaseAuthentication())
    
    var selectedFilterId: UUID?
    
    init() {
        configureBinding()
    }
    
    private let bag = DisposeBag()
    
    private func configureBinding() {
        self.filtersWorker.filters.map { (result) -> [CameraFilter] in
            switch result {
            case .Success(let operation, let filters) where operation == .fetch: return filters
            default: return []
            }
        }.subscribe(
            onNext: { [weak self] filters in
                guard let self = self else { return }
                
                let response = ListFilters.FetchFilters.Response(filters: filters)
                self.presenter?.displayFilters(response: response)
            }
        ).disposed(by: self.bag)
    }
    
    // MARK: Fetch filters
    func fetchFilters(request: ListFilters.FetchFilters.Request) {
        authenticationWorker.loggedInUser { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .Success(let user):
                self.filtersWorker.fetchFilters(user: user)
            case .Failure(let error):
                print(error)
                self.filtersWorker.fetchFilters(user: nil)
            }
        }
    }
    
    // MARK: - Select filter
    func selectFilter(request: ListFilters.SelectFilter.Request) {
        let selectedFilterId = request.filterId
        self.selectedFilterId = selectedFilterId
    }
}
