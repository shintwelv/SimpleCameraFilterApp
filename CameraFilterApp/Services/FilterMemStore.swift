//
//  FilterMemStore.swift
//  CameraFilterApp
//
//  Created by siheo on 12/1/23.
//

import Foundation
import CoreImage

class FilterMemStore: FiltersStoreProtocol {
    
    static var filters: [CameraFilter] = {
        let filters: [CameraFilter?] = [
            SepiaFilter(inputIntensity: 1.0),
            VintageFilter(),
            BlackWhiteFilter(),
            MonochromeFilter(displayName: "시안", inputColor: CIColor.cyan),
            MonochromeFilter(displayName: "로즈", inputColor: CIColor.magenta),
            MonochromeFilter(displayName: "블루", inputColor: CIColor.blue),
            BlurFilter(displayName: "블러"),
            PosterizeFilter(displayName: "포스터")
        ]
        
        return filters.compactMap {$0}
    }()
    
    func fetchFilters(completionHandler: @escaping ([CameraFilter], FiltersStoreError?) -> Void) {
        completionHandler(type(of: self).filters, nil)
    }
    
    func fetchFilter(filterId: UUID, completionHandler: @escaping (CameraFilter?, FiltersStoreError?) -> Void) {
        if let index = indexOfFilterWithID(id: filterId) {
            let filter = type(of: self).filters[index]
            completionHandler(filter, nil)
        } else {
            completionHandler(nil, FiltersStoreError.cannotFetch("해당 필터를 가져올 수 없습니다 id = \(filterId.uuidString)"))
        }
    }
    
    func createFilter(filterToCreate: CameraFilter, completionHandler: @escaping (CameraFilter?, FiltersStoreError?) -> Void) {
        let filter = filterToCreate
        type(of: self).filters.append(filter)
        completionHandler(filter, nil)
    }
    
    func updateFilter(filterToUpdate: CameraFilter, completionHandler: @escaping (CameraFilter?, FiltersStoreError?) -> Void) {
        if let index = indexOfFilterWithID(id: filterToUpdate.filterId) {
            type(of: self).filters[index] = filterToUpdate
            let filter = type(of: self).filters[index]
            completionHandler(filter, nil)
        } else {
            completionHandler(nil, FiltersStoreError.cannotUpdate("해당 필터를 수정할 수 없습니다 id = \(filterToUpdate.filterId.uuidString)"))
        }
    }
    
    func deleteFilter(filterId: UUID, completionHandler: @escaping (CameraFilter?, FiltersStoreError?) -> Void) {
        if let index = indexOfFilterWithID(id: filterId) {
            let filter = type(of: self).filters.remove(at: index)
            completionHandler(filter, nil)
        } else {
            completionHandler(nil, FiltersStoreError.cannotDelete("해당 필터를 삭제할 수 없습니다 id = \(filterId.uuidString)"))
        }
    }
    
    func fetchFilters(completionHandler: @escaping FiltersStoreFetchFiltersCompletionHandler) {
        completionHandler(FiltersStoreResult.Success(result: type(of: self).filters))
    }
    
    func fetchFilter(filterId: UUID, completionHandler: @escaping FiltersStoreFetchFilterCompletionHandler) {
        if let index = indexOfFilterWithID(id: filterId) {
            let filter = type(of: self).filters[index]
            completionHandler(FiltersStoreResult.Success(result: filter))
        } else {
            completionHandler(FiltersStoreResult.Failure(error: FiltersStoreError.cannotFetch("해당 필터를 가져올 수 없습니다 id = \(filterId.uuidString)")))
        }
    }
    
    func createFilter(filterToCreate: CameraFilter, completionHandler: @escaping FiltersStoreCreateFilterCompletionHandler) {
        let filter = filterToCreate
        type(of: self).filters.append(filter)
        completionHandler(FiltersStoreResult.Success(result: filter))
    }
    
    func updateFilter(filterToUpdate: CameraFilter, completionHandler: @escaping FiltersStoreUpdateFilterCompletionHandler) {
        if let index = indexOfFilterWithID(id: filterToUpdate.filterId) {
            type(of: self).filters[index] = filterToUpdate
            let filter = type(of: self).filters[index]
            completionHandler(FiltersStoreResult.Success(result: filter))
        } else {
            completionHandler(FiltersStoreResult.Failure(error: FiltersStoreError.cannotUpdate("해당 필터를 수정할 수 없습니다 id = \(filterToUpdate.filterId.uuidString)")))
        }
    }
    
    func deleteFilter(filterId: UUID, completionHandler: @escaping FiltersStoreDeleteFilterCompletionHandler) {
        if let index = indexOfFilterWithID(id: filterId) {
            let filter = type(of: self).filters.remove(at: index)
            completionHandler(FiltersStoreResult.Success(result: filter))
        } else {
            completionHandler(FiltersStoreResult.Failure(error: FiltersStoreError.cannotDelete("해당 필터를 삭제할 수 없습니다 id = \(filterId.uuidString)")))
        }
    }
    
    func fetchFilters(completionHandler: @escaping (() throws -> [CameraFilter]) -> Void) {
        completionHandler { return type(of: self).filters }
    }
    
    func fetchFilter(filterId: UUID, completionHandler: @escaping (() throws -> CameraFilter?) -> Void) {
        if let index = indexOfFilterWithID(id: filterId) {
            let filter = type(of: self).filters[index]
            completionHandler { return filter }
        } else {
            completionHandler { throw FiltersStoreError.cannotFetch("해당 필터를 가져올 수 없습니다 id = \(filterId.uuidString)") }
        }
    }
    
    func createFilter(filterToCreate: CameraFilter, completionHandler: @escaping (() throws -> CameraFilter?) -> Void) {
        let filter = filterToCreate
        type(of: self).filters.append(filter)
        completionHandler { return filter }
    }
    
    func updateFilter(filterToUpdate: CameraFilter, completionHandler: @escaping (() throws -> CameraFilter?) -> Void) {
        if let index = indexOfFilterWithID(id: filterToUpdate.filterId) {
            type(of: self).filters[index] = filterToUpdate
            let filter = type(of: self).filters[index]
            completionHandler { return filter }
        } else {
            completionHandler { throw FiltersStoreError.cannotUpdate("해당 필터를 수정할 수 없습니다 id = \(filterToUpdate.filterId.uuidString)") }
        }
    }
    
    func deleteFilter(filterId: UUID, completionHandler: @escaping (() throws -> CameraFilter?) -> Void) {
        if let index = indexOfFilterWithID(id: filterId) {
            let filter = type(of: self).filters.remove(at: index)
            completionHandler { return filter }
        } else {
            completionHandler { throw FiltersStoreError.cannotDelete("해당 필터를 삭제할 수 없습니다 id = \(filterId.uuidString)") }
        }
    }
    
    // MARK: - Convenience methods
    private func indexOfFilterWithID(id: UUID) -> Int? {
        return type(of:self).filters.firstIndex {$0.filterId == id}
    }
}
