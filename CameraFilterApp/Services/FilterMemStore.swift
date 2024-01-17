//
//  FilterMemStore.swift
//  CameraFilterApp
//
//  Created by siheo on 12/1/23.
//

import Foundation
import CoreImage
import RxSwift

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
    
    func fetchFilters() -> Observable<[CameraFilter]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(FiltersStoreError.cannotFetch("self is not referenced"))
                return Disposables.create()
            }
            
            observer.onNext(type(of: self).filters)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func fetchFilter(filterId: UUID) -> Observable<CameraFilter> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(FiltersStoreError.cannotFetch("self is not referenced"))
                return Disposables.create()
            }
            
            if let index = indexOfFilterWithID(id: filterId) {
                let filter = type(of: self).filters[index]
                observer.onNext(filter)
                observer.onCompleted()
            } else {
                observer.onError(FiltersStoreError.cannotFetch("해당 필터를 가져올 수 없습니다 id = \(filterId.uuidString)"))
            }
            
            return Disposables.create()
        }
    }
    
    func createFilter(filterToCreate: CameraFilter) -> Observable<CameraFilter> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(FiltersStoreError.cannotCreate("self is not referenced"))
                return Disposables.create()
            }
            
            type(of: self).filters.append(filterToCreate)
            
            observer.onNext(filterToCreate)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func updateFilter(filterToUpdate: CameraFilter) -> Observable<CameraFilter> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(FiltersStoreError.cannotUpdate("self is not referenced"))
                return Disposables.create()
            }
            
            if let index = indexOfFilterWithID(id: filterToUpdate.filterId) {
                type(of: self).filters[index] = filterToUpdate
                let filter = type(of: self).filters[index]
                
                observer.onNext(filter)
                observer.onCompleted()
            } else {
                observer.onError(FiltersStoreError.cannotUpdate("해당 필터를 수정할 수 없습니다 id = \(filterToUpdate.filterId.uuidString)"))
            }
            
            return Disposables.create()
        }
    }
    
    func deleteFilter(filterId: UUID) -> Observable<CameraFilter> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(FiltersStoreError.cannotDelete("self is not referenced"))
                return Disposables.create()
            }
            
            if let index = indexOfFilterWithID(id: filterId) {
                let filter = type(of: self).filters.remove(at: index)
                
                observer.onNext(filter)
                observer.onCompleted()
            } else {
                observer.onError(FiltersStoreError.cannotDelete("해당 필터를 삭제할 수 없습니다 id = \(filterId.uuidString)"))
            }
            
            return Disposables.create()
        }
    }
    
    // MARK: - Convenience methods
    private func indexOfFilterWithID(id: UUID) -> Int? {
        return type(of:self).filters.firstIndex {$0.filterId == id}
    }
}
