//
//  FilterFirebaseStore.swift
//  CameraFilterApp
//
//  Created by siheo on 12/26/23.
//

import Foundation
import CoreImage
import NetworkManager

class FilterFirebaseStore: RemoteFiltersStoreProtocol {
    
    static let endPoint: String = FirebaseDB.Endpoint.url.rawValue + "/" + FirebaseDB.Name.filters.rawValue
    
    func fetchFilters(user: User, completionHandler: @escaping FiltersStoreFetchFiltersCompletionHandler) {
        let userId = user.userId
        
        let url: String = "\(FilterFirebaseStore.endPoint).\(FirebaseDB.FileExt.json)?\(FirebaseDB.OrderBy.owner)&\(FirebaseDB.Filtering.equalTo(param: userId))"
        
        NetworkManager.shared.getMethod(url)?.decodableResponse(of: FilterData.self, completionHandler: { [weak self] (response: HTTPResponse<FilterData>) in
            guard let self = self else { return }
            
            switch response {
            case .Success(let data):
                var cameraFilters: [CameraFilter] = []
                
                for filterId in data.keys {
                    do {
                        let cameraFilter: CameraFilter = try self.createCameraFilter(filterId: filterId, filterData: data)
                        cameraFilters.append(cameraFilter)
                    } catch {
                        let result = FiltersStoreResult<[CameraFilter]>.Failure(error: .cannotFetch("\(error)"))
                        completionHandler(result)
                        return
                    }
                }
                
                let result = FiltersStoreResult<[CameraFilter]>.Success(result: cameraFilters)
                completionHandler(result)
            case .Fail(let error):
                let result = FiltersStoreResult<[CameraFilter]>.Failure(error: .cannotFetch(error.localizedDescription))
                completionHandler(result)
            }
        })
    }
    
    func fetchFilter(user: User, filterId: UUID, completionHandler: @escaping FiltersStoreFetchFilterCompletionHandler) {
        let url: String = "\(FilterFirebaseStore.endPoint).\(FirebaseDB.FileExt.json)?\(FirebaseDB.OrderBy.key)&\(FirebaseDB.Filtering.equalTo(param: filterId.uuidString))"
        
        NetworkManager.shared.getMethod(url)?.decodableResponse(of: FilterData.self, completionHandler: { [weak self] (response: HTTPResponse<FilterData>) in
            guard let self = self else { return }
            
            switch response {
            case .Success(let data):
                do {
                    let cameraFilter: CameraFilter = try self.createCameraFilter(filterId: data.keys.first, filterData: data)
                    let result = FiltersStoreResult<CameraFilter>.Success(result: cameraFilter)
                    completionHandler(result)
                } catch {
                    let result = FiltersStoreResult<CameraFilter>.Failure(error: .cannotCreate("\(error)"))
                    completionHandler(result)
                }
            case .Fail(let error):
                let result = FiltersStoreResult<CameraFilter>.Failure(error: .cannotFetch(error.localizedDescription))
                completionHandler(result)
            }
        })
    }
    
    func createFilter(user: User, filterToCreate: CameraFilter, completionHandler: @escaping FiltersStoreCreateFilterCompletionHandler) {
        let parameter: FilterData = self.createParams(user: user, filter: filterToCreate)
        
        let headers: [String : String] = [
            "Content-Type": FirebaseDB.ContentType.applicationJson.rawValue
        ]
        
        let url: String = "\(FilterFirebaseStore.endPoint).\(FirebaseDB.FileExt.json)"
        
        NetworkManager.shared.patchMethod(url, headers: headers, parameters: parameter, encoding: .json)?.decodableResponse(of: FilterData.self, completionHandler: { [weak self] (response: HTTPResponse<FilterData>) in
            guard let self = self else { return }
            
            switch response {
            case .Success(let data):
                do {
                    let cameraFilter: CameraFilter = try self.createCameraFilter(filterId: data.keys.first, filterData: data)
                    let result = FiltersStoreResult<CameraFilter>.Success(result: cameraFilter)
                    completionHandler(result)
                } catch {
                    let result = FiltersStoreResult<CameraFilter>.Failure(error: .cannotCreate("\(error)"))
                    completionHandler(result)
                }
            case .Fail(let error):
                let result = FiltersStoreResult<CameraFilter>.Failure(error: .cannotCreate(error.localizedDescription))
                completionHandler(result)
            }
        })
    }
    
    func updateFilter(user: User, filterToUpdate: CameraFilter, completionHandler: @escaping FiltersStoreUpdateFilterCompletionHandler) {
        let parameter: FilterData = self.createParams(user: user, filter: filterToUpdate)
        
        let headers: [String : String] = [
            "Content-Type": FirebaseDB.ContentType.applicationJson.rawValue
        ]
        
        let url: String = "\(FilterFirebaseStore.endPoint).\(FirebaseDB.FileExt.json)"
        
        NetworkManager.shared.patchMethod(url, headers: headers, parameters: parameter, encoding: .json)?.decodableResponse(of: FilterData.self, completionHandler: { [weak self] (response: HTTPResponse<FilterData>) in
            guard let self = self else { return }
            
            switch response {
            case .Success(let data):
                do {
                    let cameraFilter: CameraFilter = try self.createCameraFilter(filterId: data.keys.first, filterData: data)
                    let result = FiltersStoreResult<CameraFilter>.Success(result: cameraFilter)
                    completionHandler(result)
                } catch {
                    let result = FiltersStoreResult<CameraFilter>.Failure(error: .cannotUpdate("\(error)"))
                    completionHandler(result)
                }
            case .Fail(let error):
                let result = FiltersStoreResult<CameraFilter>.Failure(error: .cannotUpdate(error.localizedDescription))
                completionHandler(result)
            }
        })
    }
    
    func deleteFilter(user: User, filterId: UUID, completionHandler: @escaping FiltersStoreDeleteFilterCompletionHandler) {
        
        self.fetchFilter(user: user, filterId: filterId) { result in
            switch result {
            case .Success(let filterToDelete):
                let url:String = "\(FilterFirebaseStore.endPoint)/\(filterId).\(FirebaseDB.FileExt.json)"
                
                NetworkManager.shared.deleteMethod(url)?.response(completionHandler: { (response: HTTPResponse<Data?>) in
                    switch response {
                    case .Success(_):
                        let result = FiltersStoreResult<CameraFilter>.Success(result: filterToDelete)
                        completionHandler(result)
                    case .Fail(let error):
                        let result = FiltersStoreResult<CameraFilter>.Failure(error: .cannotDelete(error.localizedDescription))
                        completionHandler(result)
                    }
                })
            case .Failure(let error):
                let result = FiltersStoreResult<CameraFilter>.Failure(error: .cannotDelete("\(error)"))
                completionHandler(result)
            }
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
