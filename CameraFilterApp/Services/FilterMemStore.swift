//
//  FilterMemStore.swift
//  CameraFilterApp
//
//  Created by siheo on 12/1/23.
//

import Foundation
import CoreImage

class FilterMemStore: LocalFiltersStoreProtocol {
    
    static var filters: [CameraFilter] = {
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
    
    // MARK: - Convenience methods
    private func indexOfFilterWithID(id: UUID) -> Int? {
        return type(of:self).filters.firstIndex {$0.filterId == id}
    }
}
