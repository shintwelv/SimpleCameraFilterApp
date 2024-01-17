//
//  FilterFirebaseStore.swift
//  CameraFilterApp
//
//  Created by siheo on 12/26/23.
//

import Foundation
import CoreImage
import NetworkManager
import RxSwift

class FilterFirebaseStore: RemoteFiltersStoreProtocol {
    
    struct URLManager {
        private init() {}
        
        static let endPoint: String = FirebaseDB.Endpoint.url.rawValue + "/" + FirebaseDB.Name.filters.rawValue
        
        static let filtersJson: String = endPoint + "." + FirebaseDB.FileExt.json.rawValue
        
        static func fetchFiltersURL(userId: String) -> String {
            return filtersJson + "?"
            + orderByString(orderBy: .owner, param: userId)
        }
        
        static func fetchFilterURL(filterId: UUID) -> String {
            return filtersJson + "?"
            + orderByString(orderBy: .key, param: filterId.uuidString)
        }
        
        static func createFilterURL() -> String {
            return filtersJson
        }
        
        static func updateFilterURL() -> String {
            return filtersJson
        }
        
        static func deleteFilterURL(filterId: UUID) -> String {
            return endPoint + "/"
            + filterId.uuidString + FirebaseDB.FileExt.json.rawValue
        }
        
        static private func orderByString(orderBy: FirebaseDB.OrderBy, param: String) -> String {
            return orderBy.description + "&"
            + FirebaseDB.Filtering.equalTo(param: param).description
        }
    }
    
    private var disposeBag = DisposeBag()
    
    func fetchFilters(user: User) -> Observable<[CameraFilter]> {
        let userId = user.userId
        let url: String = URLManager.fetchFiltersURL(userId: userId)
        
        guard let networkResponse = NetworkManager.shared.getMethod(url) else {
            return Observable.error(FiltersStoreError.cannotFetch("invalid request"))
        }
        
        return networkResponse
            .decodableResponse(of: FilterData.self)
            .map { [weak self] (filterData: FilterData) -> [CameraFilter] in
                guard let self = self else {
                    throw FiltersStoreError.cannotFetch("self is not referenced")
                }
                
                var cameraFilters: [CameraFilter] = []
                
                for filterId in filterData.keys {
                    do {
                        let cameraFilter: CameraFilter = try self.createCameraFilter(filterId: filterId, filterData: filterData)
                        cameraFilters.append(cameraFilter)
                    } catch {
                        throw error
                    }
                }
                
                return cameraFilters
            }.catch { error in
                return Observable.error(error)
            }
    }
    
    func fetchFilter(user: User, filterId: UUID) -> Observable<CameraFilter> {
        let url: String = URLManager.fetchFilterURL(filterId: filterId)
        
        guard let networkResponse = NetworkManager.shared.getMethod(url) else {
            return Observable.error(FiltersStoreError.cannotFetch("invalid request"))
        }
        
        return networkResponse
            .decodableResponse(of: FilterData.self)
            .map { [weak self] (filterData: FilterData) -> CameraFilter in
                guard let self = self else {
                    throw FiltersStoreError.cannotFetch("self is not referred")
                }
                
                do {
                    return try self.createCameraFilter(filterId: filterData.keys.first, filterData: filterData)
                } catch {
                    throw error
                }
                
                
            }.catch { error in
                return Observable.error(error)
            }
    }
    
    func createFilter(user: User, filterToCreate: CameraFilter) -> Observable<CameraFilter> {
        let parameter: FilterData = self.createParams(user: user, filter: filterToCreate)
        
        let headers: [HTTPRequestHeaderKey : HTTPRequestHeaderValue] = [
            .contentType : .applicationJson
        ]
        
        let url: String = URLManager.createFilterURL()
        
        guard let networkResponse = NetworkManager.shared.patchMethod(url, headers: headers, parameters: parameter, encoding: .json) else {
            return Observable.error(FiltersStoreError.cannotCreate("invalid request"))
        }
        
        return networkResponse
            .decodableResponse(of: FilterData.self)
            .map { [weak self] (filterData: FilterData) -> CameraFilter in
                guard let self = self else {
                    throw FiltersStoreError.cannotCreate("self is not referred")
                }
                
                do {
                    return try self.createCameraFilter(filterId: filterData.keys.first, filterData: filterData)
                } catch {
                    throw error
                }
                
            }.catch { error in
                return Observable.error(error)
            }
    }
    
    func updateFilter(user: User, filterToUpdate: CameraFilter) -> Observable<CameraFilter> {
        let parameter: FilterData = self.createParams(user: user, filter: filterToUpdate)
        
        let headers: [HTTPRequestHeaderKey : HTTPRequestHeaderValue] = [
            .contentType : .applicationJson
        ]
        
        let url: String = URLManager.updateFilterURL()
        
        guard let networkResponse = NetworkManager.shared.patchMethod(url, headers: headers, parameters: parameter, encoding: .json) else {
            return Observable.error(FiltersStoreError.cannotUpdate("invalid request"))
        }
        
        return networkResponse
            .decodableResponse(of: FilterData.self)
            .map { [weak self] (filterData: FilterData) -> CameraFilter in
                guard let self = self else {
                    throw FiltersStoreError.cannotUpdate("self is not referenced")
                }
                
                do {
                    return try self.createCameraFilter(filterId: filterData.keys.first, filterData: filterData)
                } catch {
                    throw error
                }
            }.catch { error in
                return Observable.error(error)
            }
    }
    
    func deleteFilter(user: User, filterId: UUID) -> Observable<CameraFilter> {
        return self.fetchFilter(user: user, filterId: filterId)
            .flatMap { filterToDelete in
                let url:String = URLManager.deleteFilterURL(filterId: filterId)
                
                guard let networkResponse = NetworkManager.shared.deleteMethod(url) else {
                    throw FiltersStoreError.cannotDelete("invalid request")
                }
                
                return networkResponse
                    .response()
                    .map { _ in
                        return filterToDelete
                    }
            }
            .catch { error in
                return Observable.error(error)
            }
    }
    
    typealias FilterData = [String: [String : String]]
    
    private func createParams(user: User, filter: CameraFilter) -> FilterData {
        return [
            filter.filterId.uuidString: [
                "owner": user.userId,
                "alias": filter.displayName,
                "inputColor": filter.inputColor?.stringRepresentation ?? "0 0 0 0",
                "inputIntensity": "\(filter.inputIntensity ?? 0.0)",
                "inputLevels": "\(filter.inputLevels ?? 0.0)",
                "inputRadius": "\(filter.inputRadius ?? 0.0)",
                "systemName": filter.systemName.rawValue
            ]
        ]
    }
    
    enum CreateFilterError: LocalizedError {
        case noFilterData(String)
        case invalidProperty(String)
        
        var errorDescription: String? {
            switch self {
            case .noFilterData(let string), .invalidProperty(let string):
                return string
            }
        }
    }
    
    private func createCameraFilter(filterId: String?, filterData:[String : [String : String]]) throws -> CameraFilter {
        guard let filterId = UUID(uuidString: filterId ?? ""),
              let filterData: [String: String] = filterData[filterId.uuidString],
              let systemName = CameraFilter.FilterName(rawValue: filterData["systemName", default: ""]),
              let displayName = filterData["alias"] else {
            throw CreateFilterError.noFilterData("필터 정보가 존재하지 않습니다")
        }
        
        var cameraFilter: CameraFilter?
        switch systemName {
        case .CISepiaTone:
            guard let inputIntensity = Double(filterData["inputIntensity", default: ""]) else {
                throw CreateFilterError.invalidProperty("필터의 속성이 유효하지 않습니다")
            }
            
            cameraFilter = CameraFilter.createSepiaFilter(filterId: filterId, displayName: displayName, inputIntensity: inputIntensity)
        case .CIPhotoEffectTransfer:
            cameraFilter = CameraFilter.createVintageFilter(filterId: filterId, displayName: displayName)
        case .CIPhotoEffectTonal:
            cameraFilter = CameraFilter.createBlackWhiteFilter(filterId: filterId, displayName: displayName)
        case .CIColorMonochrome:
            guard let inputColorString = filterData["inputColor"],
                  let inputIntensity = Double(filterData["inputIntensity", default: ""]) else {
                throw CreateFilterError.invalidProperty("필터의 속성이 유효하지 않습니다")
            }
            
            let inputColor = CIColor(string: inputColorString)
            
            cameraFilter = CameraFilter.createMonochromeFilter(filterId: filterId, displayName: displayName, inputColor: inputColor, inputIntensity: inputIntensity)
        case .CIColorPosterize:
            guard let inputLevels = Double(filterData["inputLevels", default: ""]) else {
                throw CreateFilterError.invalidProperty("필터의 속성이 유효하지 않습니다")
            }
            
            cameraFilter = CameraFilter.createPosterizeFilter(filterId: filterId, displayName: displayName, inputLevels: inputLevels)
        case .CIBoxBlur:
            guard let inputRadius = Double(filterData["inputRadius", default: ""]) else {
                throw CreateFilterError.invalidProperty("필터의 속성이 유효하지 않습니다")
            }
            
            cameraFilter = CameraFilter.createBlurFilter(filterId: filterId, displayName: displayName, inputRadius: inputRadius)
        }
        
        if let cameraFilter = cameraFilter {
            return cameraFilter
        } else {
            throw CreateFilterError.invalidProperty("필터의 속성이 유효하지 않습니다")
        }
    }
}
