//
//  CreateFilterInteractor.swift
//  CameraFilterApp
//
//  Created by ShinIl Heo on 12/2/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

protocol CreateFilterBusinessLogic
{
    func fetchFilter(request: CreateFilter.FetchFilter.Request)
    func fetchFilterCategories(request: CreateFilter.FetchFilterCategories.Request)
    func fetchProperties(request: CreateFilter.FetchProperties.Request)
    func applyFilter(request: CreateFilter.ApplyFilter.Request)
    func createFilter(request: CreateFilter.CreateFilter.Request)
    func editFilter(request: CreateFilter.EditFilter.Request)
    func deleteFilter(request: CreateFilter.DeleteFilter.Request)
}

protocol CreateFilterDataStore
{
    var filterId: UUID? { get set }
}

class CreateFilterInteractor: CreateFilterBusinessLogic, CreateFilterDataStore
{
    var presenter: CreateFilterPresentationLogic?
    var filtersWorker: FiltersWorker = FiltersWorker(filtersStore: FilterMemStore())
    
    var filterId: UUID?
    
    // MARK: CRUD operations
    func fetchFilter(request: CreateFilter.FetchFilter.Request) {
        if let filterId = self.filterId {
            self.presenter?.isEditingFilter.onNext(true)
            filtersWorker.fetchFilter(filterId: filterId) { [weak self] filter in
                self?.sendCameraFilter(filter: filter, operation: .fetch)
            }
        } else {
            self.presenter?.isEditingFilter.onNext(false)
        }
    }
    
    func fetchFilterCategories(request: CreateFilter.FetchFilterCategories.Request) {
        let filterCategories: [CameraFilter.FilterName] = CameraFilter.FilterName.allCases
        
        self.presenter?.filterCategories.onNext(filterCategories)
    }
    
    func fetchProperties(request: CreateFilter.FetchProperties.Request) {
        let filterSystemName = request.filterSystemName
        
        let defaultFilter: CameraFilter? = createDefaultFilter(filterSystemName: filterSystemName)
        
        self.sendCameraFilter(filter: defaultFilter, operation: .fetch)
    }
    
    func applyFilter(request: CreateFilter.ApplyFilter.Request) {
        let filterSystemName = request.filterSystemName
        let inputColor = request.inputColor
        let inputIntensity = request.inputIntensity
        let inputRadius = request.inputRadius
        let inputLevels = request.inputLevels
        
        let filter: CameraFilter? = createFilter(filterId: UUID(),
                                                 displayName: "",
                                                 systemName: filterSystemName,
                                                 inputColor: inputColor,
                                                 inputIntensity: inputIntensity,
                                                 inputRadius: inputRadius,
                                                 inputLevels: inputLevels)
        
        if let filter = filter {
            self.presenter?.cameraFilterResult.onNext(CreateFilter.CameraFilterResult.Success(operation: .fetch, result: filter))
        } else {
            self.presenter?.cameraFilterResult.onNext(CreateFilter.CameraFilterResult.Fail(error: .cannotFetch("필터를 적용할 수 없습니다")))
        }
    }
    
    func createFilter(request: CreateFilter.CreateFilter.Request) {
        let filterName = request.filterName
        let filterSystemName = request.filterSystemName
        let inputColor = request.inputColor
        let inputIntensity = request.inputIntensity
        let inputRadius = request.inputRadius
        let inputLevels = request.inputLevels
        
        let filter: CameraFilter? = createFilter(filterId: UUID(),
                                                 displayName: filterName,
                                                 systemName: filterSystemName,
                                                 inputColor: inputColor,
                                                 inputIntensity: inputIntensity, 
                                                 inputRadius: inputRadius,
                                                 inputLevels: inputLevels)
        
        guard let filter = filter else {
            self.presenter?.cameraFilterResult.onNext(CreateFilter.CameraFilterResult.Fail(error: .cannotCreate("필터를 생성할 수 없습니다")))
            return
        }
        
        filtersWorker.createFilter(filterToCreate: filter) { [weak self] filter in
            self?.sendCameraFilter(filter: filter, operation: .create)
        }
    }
    
    func editFilter(request: CreateFilter.EditFilter.Request) {
        guard let filterId = self.filterId else { return }

        let filterName = request.filterName
        let filterSystemName = request.filterSystemName
        let inputColor = request.inputColor
        let inputIntensity = request.inputIntensity
        let inputRadius = request.inputRadius
        let inputLevels = request.inputLevels
        
        let filterToUpdate = createFilter(filterId: filterId,
                                          displayName: filterName,
                                          systemName: filterSystemName,
                                          inputColor: inputColor,
                                          inputIntensity: inputIntensity,
                                          inputRadius: inputRadius,
                                          inputLevels: inputLevels)
        
        guard let filterToUpdate = filterToUpdate else {
            self.presenter?.cameraFilterResult.onNext(CreateFilter.CameraFilterResult.Fail(error: .cannotEdit("필터를 수정할 수 없습니다")))
            return
        }
        
        filtersWorker.updateFilter(filterToUpdate: filterToUpdate) { [weak self] filter in
            self?.sendCameraFilter(filter: filter, operation: .edit)
        }
    }
    
    func deleteFilter(request: CreateFilter.DeleteFilter.Request) {
        guard let filterId = self.filterId else { return }
        
        filtersWorker.deleteFilter(filterId: filterId) { [weak self] filter in
            self?.sendCameraFilter(filter: filter, operation: .delete)
        }
    }
    
    //MARK: - private methods
    private func sendCameraFilter(filter: CameraFilter?, operation: CreateFilter.FilterOperation) {
        if let filter = filter {
            self.presenter?.cameraFilterResult.onNext(CreateFilter.CameraFilterResult.Success(operation: operation, result: filter))
        } else {
            switch operation {
            case .fetch:
                self.presenter?.cameraFilterResult.onNext(CreateFilter.CameraFilterResult.Fail(error: .cannotFetch("필터 정보를 가져올 수 없습니다")))
            case .edit:
                self.presenter?.cameraFilterResult.onNext(CreateFilter.CameraFilterResult.Fail(error: .cannotEdit("필터를 수정할 수 없습니다")))
            case .create:
                self.presenter?.cameraFilterResult.onNext(CreateFilter.CameraFilterResult.Fail(error: .cannotCreate("필터를 생성할 수 없습니다")))
            case .delete:
                self.presenter?.cameraFilterResult.onNext(CreateFilter.CameraFilterResult.Fail(error: .cannotDelete("필터를 삭제할 수 없습니다")))
            }
        }
    }
    
    private func createDefaultFilter(filterSystemName: CameraFilter.FilterName) -> CameraFilter? {
        switch filterSystemName {
        case .CISepiaTone:
            return CameraFilter.createSepiaFilter(filterId: UUID(), displayName: "", inputIntensity: 1.0)
        case .CIPhotoEffectTonal:
            return CameraFilter.createBlackWhiteFilter(filterId: UUID(), displayName: "")
        case .CIPhotoEffectTransfer:
            return CameraFilter.createVintageFilter(filterId: UUID(), displayName: "")
        case .CIColorMonochrome:
            return CameraFilter.createMonochromeFilter(filterId: UUID(), displayName: "", inputColor: CIColor(cgColor: UIColor.systemBlue.cgColor), inputIntensity: 1.0)
        case .CIColorPosterize:
            return CameraFilter.createPosterizeFilter(filterId: UUID(), displayName: "", inputLevels: 6.0)
        case .CIBoxBlur:
            return CameraFilter.createBlurFilter(filterId: UUID(), displayName: "", inputRadius: 10.0)
        }
    }
    
    private func createFilter(filterId: UUID,
                              displayName: String,
                              systemName: CameraFilter.FilterName,
                              inputColor: UIColor?,
                              inputIntensity: CGFloat?,
                              inputRadius: CGFloat?,
                              inputLevels: CGFloat?) -> CameraFilter? {

        switch systemName {
        case .CISepiaTone:
            guard let inputIntensity = inputIntensity else { break }
            
            return CameraFilter.createSepiaFilter(filterId: filterId, displayName: displayName, inputIntensity: inputIntensity)
        case .CIPhotoEffectTransfer:
            return CameraFilter.createVintageFilter(filterId: filterId, displayName: displayName)
        case .CIPhotoEffectTonal:
            return CameraFilter.createBlackWhiteFilter(filterId: filterId, displayName: displayName)
        case .CIColorMonochrome:
            guard let inputColor = inputColor,
                  let inputIntensity = inputIntensity else { break }
            
            return CameraFilter.createMonochromeFilter(filterId: filterId, displayName: displayName, inputColor: CIColor(color: inputColor), inputIntensity: inputIntensity)
        case .CIColorPosterize:
            guard let inputLevels = inputLevels else { break }
            
            return CameraFilter.createPosterizeFilter(filterId: filterId, displayName: displayName, inputLevels: inputLevels)
        case .CIBoxBlur:
            guard let inputRadius = inputRadius else { break }
            
            return CameraFilter.createBlurFilter(filterId: filterId, displayName: displayName, inputRadius: inputRadius)
        }
        
        return nil
    }
}
