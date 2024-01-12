//
//  FiltersWorker.swift
//  CameraFilterApp
//
//  Created by siheo on 12/1/23.
//

import Foundation
import RxSwift

class FiltersWorker {
    
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
    }
    
    let bag = DisposeBag()
    
    func fetchFilters(user: User?) -> Observable<[CameraFilter]> {
        if let user = user {
            return remoteStore.fetchFilters(user: user)
        } else {
            return localStore.fetchFilters()
        }
    }
    
    func fetchFilter(user: User?, filterId: UUID) -> Observable<CameraFilter> {
        if let user = user {
            return remoteStore.fetchFilter(user: user, filterId: filterId)
        } else {
            return localStore.fetchFilter(filterId: filterId)
        }
    }
    
    func createFilter(user: User?, filterToCreate: CameraFilter) -> Observable<CameraFilter> {
        if let user = user {
            return remoteStore.createFilter(user: user, filterToCreate: filterToCreate)
        } else {
            return localStore.createFilter(filterToCreate: filterToCreate)
        }
    }
    
    func updateFilter(user: User?, filterToUpdate: CameraFilter) -> Observable<CameraFilter> {
        if let user = user {
            return remoteStore.updateFilter(user: user, filterToUpdate: filterToUpdate)
        } else {
            return localStore.updateFilter(filterToUpdate: filterToUpdate)
        }
    }
    
    func deleteFilter(user: User?, filterId: UUID) -> Observable<CameraFilter> {
        if let user = user {
            return remoteStore.deleteFilter(user: user, filterId: filterId)
        } else {
            return localStore.deleteFilter(filterId: filterId)
        }
    }
}

protocol RemoteFiltersStoreProtocol {
    func fetchFilters(user:User) -> Observable<[CameraFilter]>
    func fetchFilter(user:User, filterId: UUID) -> Observable<CameraFilter>
    func createFilter(user:User, filterToCreate: CameraFilter) -> Observable<CameraFilter>
    func updateFilter(user:User, filterToUpdate: CameraFilter) -> Observable<CameraFilter>
    func deleteFilter(user:User, filterId: UUID) -> Observable<CameraFilter>
}

protocol LocalFiltersStoreProtocol {
    func fetchFilters() -> Observable<[CameraFilter]>
    func fetchFilter(filterId: UUID) -> Observable<CameraFilter>
    func createFilter(filterToCreate: CameraFilter) -> Observable<CameraFilter>
    func updateFilter(filterToUpdate: CameraFilter) -> Observable<CameraFilter>
    func deleteFilter(filterId: UUID) -> Observable<CameraFilter>
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
