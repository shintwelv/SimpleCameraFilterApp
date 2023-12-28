//
//  FiltersWorker.swift
//  CameraFilterApp
//
//  Created by siheo on 12/1/23.
//

import Foundation
import RxSwift

class FiltersWorker {
    enum OperationError: Equatable, LocalizedError {
        case cannotFetch(String)
        case cannotCreate(String)
        case cannotUpdate(String)
        case cannotDelete(String)
        
        var errorDescription: String? {
            switch self {
            case .cannotFetch(let string), .cannotCreate(let string), .cannotUpdate(let string), .cannotDelete(let string):
                return string
            }
        }
    }
    
    enum Operation {
        case fetch
        case create
        case delete
        case update
    }
    
    enum OperationResult<U> {
        case Success(operation: Operation, result:U)
        case Failure(error: OperationError)
    }
    
    static let initialFilters: [CameraFilter] = {
        let filters: [CameraFilter?] = [
            CameraFilter.createSepiaFilter(filterId: UUID(), displayName: "세피아", inputIntensity: 1.0),
            CameraFilter.createVintageFilter(filterId: UUID(), displayName: "빈티지"),
            CameraFilter.createMonochromeFilter(filterId: UUID(), displayName: "시안", inputColor: .cyan, inputIntensity: 1.0),
            CameraFilter.createMonochromeFilter(filterId: UUID(), displayName: "로즈", inputColor: .magenta, inputIntensity: 1.0),
            CameraFilter.createMonochromeFilter(filterId: UUID(), displayName: "블루", inputColor: .blue, inputIntensity: 1.0),
            CameraFilter.createBlurFilter(filterId: UUID(), displayName: "블러", inputRadius: 1.0),
            CameraFilter.createPosterizeFilter(filterId: UUID(), displayName: "포스터", inputLevels: 6.0),
        ]
        
        return filters.compactMap {$0}
    }()
    
    var localStore: LocalFiltersStoreProtocol
    var remoteStore: RemoteFiltersStoreProtocol
    
    init(remoteStore: RemoteFiltersStoreProtocol, localStore: LocalFiltersStoreProtocol) {
        self.localStore = localStore
        self.remoteStore = remoteStore
        
        configureDataBinding()
    }
    
    var filters = PublishSubject<OperationResult<[CameraFilter]>>()
    var filter = PublishSubject<OperationResult<CameraFilter>>()
    
    var fetchedFilters = PublishSubject<FiltersStoreResult<[CameraFilter]>>()
    var fetchedFilter = PublishSubject<FiltersStoreResult<CameraFilter>>()
    var createdFilter = PublishSubject<FiltersStoreResult<CameraFilter>>()
    var updatedFilter = PublishSubject<FiltersStoreResult<CameraFilter>>()
    var deletedFilter = PublishSubject<FiltersStoreResult<CameraFilter>>()
    
    let bag = DisposeBag()
    
    private func configureDataBinding() {
        fetchedFilters.subscribe(
            onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .Success(let result):
                    self.filters.onNext(OperationResult.Success(operation: .fetch, result: result))
                case .Failure(let error):
                    print(error)
                    self.filters.onNext(OperationResult.Failure(error: OperationError.cannotFetch(error.localizedDescription)))
                }
            }
        ).disposed(by: self.bag)
        
        fetchedFilter.subscribe(
            onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .Success(let result):
                    self.filter.onNext(OperationResult.Success(operation: .fetch, result: result))
                case .Failure(let error):
                    print(error)
                    self.filter.onNext(OperationResult.Failure(error: OperationError.cannotFetch(error.localizedDescription)))
                }
            }
        ).disposed(by: self.bag)
        
        createdFilter.subscribe(
            onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .Success(let result):
                    self.filter.onNext(OperationResult.Success(operation: .create, result: result))
                case .Failure(let error):
                    print(error)
                    self.filter.onNext(OperationResult.Failure(error: OperationError.cannotCreate(error.localizedDescription)))
                }
            }
        ).disposed(by: self.bag)
        
        updatedFilter.subscribe(
            onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .Success(let result):
                    self.filter.onNext(OperationResult.Success(operation: .update, result: result))
                case .Failure(let error):
                    print(error)
                    self.filter.onNext(OperationResult.Failure(error: OperationError.cannotUpdate(error.localizedDescription)))
                }
            }
        ).disposed(by: self.bag)
        
        deletedFilter.subscribe(
            onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .Success(let result):
                    self.filter.onNext(OperationResult.Success(operation: .delete, result: result))
                case .Failure(let error):
                    print(error)
                    self.filter.onNext(OperationResult.Failure(error: OperationError.cannotDelete(error.localizedDescription)))
                }
            }
        ).disposed(by: self.bag)
    }
    
    func fetchFilters(user: User?) {
        if let user = user {
            remoteStore.fetchFilters(user: user) { [weak self] result in
                guard let self = self else { return }
                self.fetchedFilters.onNext(result)
            }
        } else {
            localStore.fetchFilters { [weak self] result in
                guard let self = self else { return }
                self.fetchedFilters.onNext(result)
            }
        }
    }
    
    func fetchFilter(user: User?, filterId: UUID) {
        if let user = user {
            remoteStore.fetchFilter(user: user, filterId: filterId) { [weak self] result in
                guard let self = self else { return }
                self.fetchedFilter.onNext(result)
            }
        } else {
            localStore.fetchFilter(filterId: filterId) { [weak self] result in
                guard let self = self else { return }
                self.fetchedFilter.onNext(result)
            }
        }
    }
    
    func createFilter(user: User?, filterToCreate: CameraFilter) {
        if let user = user {
            remoteStore.createFilter(user:user, filterToCreate: filterToCreate) { [weak self] result in
                guard let self = self else { return }
                self.createdFilter.onNext(result)
            }
        } else {
            localStore.createFilter(filterToCreate: filterToCreate) { [weak self] result in
                guard let self = self else { return }
                self.createdFilter.onNext(result)
            }
        }
    }
    
    func updateFilter(user: User?, filterToUpdate: CameraFilter) {
        if let user = user {
            remoteStore.updateFilter(user: user, filterToUpdate: filterToUpdate) { [weak self] result in
                guard let self = self else { return }
                self.updatedFilter.onNext(result)
            }
        } else {
            localStore.updateFilter(filterToUpdate: filterToUpdate) { [weak self] result in
                guard let self = self else { return }
                self.updatedFilter.onNext(result)
            }
        }
    }
    
    func deleteFilter(user: User?, filterId: UUID) {
        if let user = user {
            remoteStore.deleteFilter(user: user, filterId: filterId) { [weak self] result in
                guard let self = self else { return }
                self.deletedFilter.onNext(result)
            }
        } else {
            localStore.deleteFilter(filterId: filterId) { [weak self] result in
                guard let self = self else { return }
                self.deletedFilter.onNext(result)
            }
        }
    }
}

func ==(lhs: FiltersWorker.OperationError, rhs: FiltersWorker.OperationError) -> Bool {
    switch (lhs, rhs) {
    case (.cannotFetch(let a), .cannotFetch(let b)) where a == b: return true
    case (.cannotCreate(let a), .cannotCreate(let b)) where a == b: return true
    case (.cannotUpdate(let a), .cannotUpdate(let b)) where a == b: return true
    case (.cannotDelete(let a), .cannotDelete(let b)) where a == b: return true
    default: return false
    }
}

protocol RemoteFiltersStoreProtocol {
    func fetchFilters(user:User, completionHandler: @escaping FiltersStoreFetchFiltersCompletionHandler)
    func fetchFilter(user:User, filterId: UUID, completionHandler: @escaping FiltersStoreFetchFilterCompletionHandler)
    func createFilter(user:User, filterToCreate: CameraFilter, completionHandler: @escaping FiltersStoreCreateFilterCompletionHandler)
    func updateFilter(user:User, filterToUpdate: CameraFilter, completionHandler: @escaping FiltersStoreUpdateFilterCompletionHandler)
    func deleteFilter(user:User, filterId: UUID, completionHandler: @escaping FiltersStoreDeleteFilterCompletionHandler)
}

protocol LocalFiltersStoreProtocol {
    func fetchFilters(completionHandler: @escaping FiltersStoreFetchFiltersCompletionHandler)
    func fetchFilter(filterId: UUID, completionHandler: @escaping FiltersStoreFetchFilterCompletionHandler)
    func createFilter(filterToCreate: CameraFilter, completionHandler: @escaping FiltersStoreCreateFilterCompletionHandler)
    func updateFilter(filterToUpdate: CameraFilter, completionHandler: @escaping FiltersStoreUpdateFilterCompletionHandler)
    func deleteFilter(filterId: UUID, completionHandler: @escaping FiltersStoreDeleteFilterCompletionHandler)
}

typealias FiltersStoreFetchFiltersCompletionHandler = (FiltersStoreResult<[CameraFilter]>) -> Void
typealias FiltersStoreFetchFilterCompletionHandler = (FiltersStoreResult<CameraFilter>) -> Void
typealias FiltersStoreCreateFilterCompletionHandler = (FiltersStoreResult<CameraFilter>) -> Void
typealias FiltersStoreUpdateFilterCompletionHandler = (FiltersStoreResult<CameraFilter>) -> Void
typealias FiltersStoreDeleteFilterCompletionHandler = (FiltersStoreResult<CameraFilter>) -> Void

enum FiltersStoreResult<U> {
    case Success(result: U)
    case Failure(error: FiltersStoreError)
}

enum FiltersStoreError: Equatable, LocalizedError {
    case cannotFetch(String)
    case cannotCreate(String)
    case cannotUpdate(String)
    case cannotDelete(String)
    
    var errorDescription: String? {
        switch self {
        case .cannotFetch(let string), .cannotCreate(let string), .cannotUpdate(let string), .cannotDelete(let string):
            return string
        }
    }
}

func ==(lhs: FiltersStoreError, rhs: FiltersStoreError) -> Bool {
    switch (lhs, rhs) {
    case (.cannotFetch(let a), .cannotFetch(let b)) where a == b: return true
    case (.cannotCreate(let a), .cannotCreate(let b)) where a == b: return true
    case (.cannotUpdate(let a), .cannotUpdate(let b)) where a == b: return true
    case (.cannotDelete(let a), .cannotDelete(let b)) where a == b: return true
    default: return false
    }
}
