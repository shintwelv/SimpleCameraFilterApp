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
    
    var filtersStore: FiltersStoreProtocol
    
    init(filtersStore: FiltersStoreProtocol) {
        self.filtersStore = filtersStore
    }
    
    var filters = PublishSubject<OperationResult<[CameraFilter]>>()
    var filter = PublishSubject<OperationResult<CameraFilter>>()
    
    func fetchFilters() {
        filtersStore.fetchFilters { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .Success(let result):
                self.filters.onNext(OperationResult.Success(operation: .fetch, result: result))
            case .Failure(let error):
                self.filters.onNext(OperationResult.Failure(error: OperationError.cannotFetch(error.localizedDescription)))
            }
        }
    }
    
    func fetchFilter(filterId: UUID) {
        filtersStore.fetchFilter(filterId: filterId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .Success(let result):
                self.filter.onNext(OperationResult.Success(operation: .fetch, result: result))
            case .Failure(let error):
                print(error)
                self.filter.onNext(OperationResult.Failure(error: OperationError.cannotFetch(error.localizedDescription)))
            }
        }
    }
    
    func createFilter(filterToCreate: CameraFilter) {
        filtersStore.createFilter(filterToCreate: filterToCreate) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .Success(let result):
                self.filter.onNext(OperationResult.Success(operation: .create, result: result))
            case .Failure(let error):
                self.filter.onNext(OperationResult.Failure(error: OperationError.cannotCreate(error.localizedDescription)))
            }
        }
    }
    
    func updateFilter(filterToUpdate: CameraFilter) {
        filtersStore.updateFilter(filterToUpdate: filterToUpdate) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .Success(let result):
                self.filter.onNext(OperationResult.Success(operation: .update, result: result))
            case .Failure(let error):
                self.filter.onNext(OperationResult.Failure(error: OperationError.cannotUpdate(error.localizedDescription)))
            }
        }
    }
    
    func deleteFilter(filterId: UUID) {
        filtersStore.deleteFilter(filterId: filterId) { result in
            switch result {
            case .Success(let result):
                self.filter.onNext(OperationResult.Success(operation: .delete, result: result))
            case .Failure(let error):
                self.filter.onNext(OperationResult.Failure(error: OperationError.cannotDelete(error.localizedDescription)))
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

protocol FiltersStoreProtocol {
    
    // MARK: - CRUD operations - Optional error
    func fetchFilters(completionHandler: @escaping ([CameraFilter], FiltersStoreError?) -> Void)
    func fetchFilter(filterId: UUID, completionHandler: @escaping (CameraFilter?, FiltersStoreError?) -> Void)
    func createFilter(filterToCreate: CameraFilter, completionHandler: @escaping (CameraFilter?, FiltersStoreError?) -> Void)
    func updateFilter(filterToUpdate: CameraFilter, completionHandler: @escaping (CameraFilter?, FiltersStoreError?) -> Void)
    func deleteFilter(filterId: UUID, completionHandler: @escaping (CameraFilter?, FiltersStoreError?) -> Void)
    
    // MARK: - CRUD operations - Generic enum result type
    func fetchFilters(completionHandler: @escaping FiltersStoreFetchFiltersCompletionHandler)
    func fetchFilter(filterId: UUID, completionHandler: @escaping FiltersStoreFetchFilterCompletionHandler)
    func createFilter(filterToCreate: CameraFilter, completionHandler: @escaping FiltersStoreCreateFilterCompletionHandler)
    func updateFilter(filterToUpdate: CameraFilter, completionHandler: @escaping FiltersStoreUpdateFilterCompletionHandler)
    func deleteFilter(filterId: UUID, completionHandler: @escaping FiltersStoreDeleteFilterCompletionHandler)
    
    // MARK: - CRUD operations - Inner closure
    func fetchFilters(completionHandler: @escaping (() throws -> [CameraFilter]) -> Void)
    func fetchFilter(filterId: UUID, completionHandler: @escaping (() throws -> CameraFilter?) -> Void)
    func createFilter(filterToCreate: CameraFilter, completionHandler: @escaping (() throws -> CameraFilter?) -> Void)
    func updateFilter(filterToUpdate: CameraFilter, completionHandler: @escaping (() throws -> CameraFilter?) -> Void)
    func deleteFilter(filterId: UUID, completionHandler: @escaping (() throws -> CameraFilter?) -> Void)
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
