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
    var userWorker: UserWorker = UserWorker(store: UserFirebaseStore(), authentication: FirebaseAuthentication())
    
    var selectedFilterId: UUID?
    
    private let bag = DisposeBag()
    
    // MARK: Fetch filters
    func fetchFilters(request: ListFilters.FetchFilters.Request) {
        userWorker.fetchCurrentlyLoggedInUser()
            .subscribe(
                onNext: { [weak self] user in
                    guard let self = self else { return }
                    
                    self.filtersWorker.fetchFilters(user: user)
                        .subscribe(
                            onNext: { filters in
                                self.presentFilters(filters: filters)
                            },
                            onError: { error in
                                print(error)
                                self.presentFilters(filters: [])
                            }
                        )
                        .disposed(by: self.bag)
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    
                    print(error)
                    self.presentFilters(filters: [])
                }
            )
            .disposed(by: self.bag)
    }
    
    // MARK: - Select filter
    func selectFilter(request: ListFilters.SelectFilter.Request) {
        let selectedFilterId = request.filterId
        self.selectedFilterId = selectedFilterId
    }

    //MARK: - Private methods
    private func presentFilters(filters: [CameraFilter]) {
        let response = ListFilters.FetchFilters.Response(filters: filters)
        self.presenter?.displayFilters(response: response)
    }
}
