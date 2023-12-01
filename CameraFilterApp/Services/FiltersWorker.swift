//
//  FiltersWorker.swift
//  CameraFilterApp
//
//  Created by siheo on 12/1/23.
//

import Foundation

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

enum FiltersStoreError: Equatable, Error {
    case cannotFetch(String)
    case cannotCreate(String)
    case cannotUpdate(String)
    case cannotDelete(String)
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
