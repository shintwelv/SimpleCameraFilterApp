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
            filtersWorker.fetchFilter(filterId: filterId) { [weak self] filter in
                guard let self = self else { return }
                
                guard let filter = filter else {
                    let response = CreateFilter.FetchFilter.Response(filter: nil)
                    self.presenter?.presentFetchedFilter(response: response)
                    return
                }
                
                let response = CreateFilter.FetchFilter.Response(filter: filter)
                self.presenter?.presentFetchedFilter(response: response)
            }
        }
    }
    
    func fetchFilterCategories(request: CreateFilter.FetchFilterCategories.Request) {
        let filterCategories: [CameraFilter.FilterName] = CameraFilter.FilterName.allCases
        
        let response = CreateFilter.FetchFilterCategories.Response(filterCategories: filterCategories)
        presenter?.presentFetchedCategories(response: response)
    }
    
    func fetchProperties(request: CreateFilter.FetchProperties.Request) {
        let filterSystemName = request.filterSystemName
        
        var filter: CameraFilter?
        switch filterSystemName {
        case .CISepiaTone:
            filter = CameraFilter.createSepiaFilter(filterId: UUID(), displayName: "", inputIntensity: 1.0)
        case .CIPhotoEffectTonal:
            filter = CameraFilter.createBlackWhiteFilter(filterId: UUID(), displayName: "")
        case .CIPhotoEffectTransfer:
            filter = CameraFilter.createVintageFilter(filterId: UUID(), displayName: "")
        case .CIColorMonochrome:
            filter = CameraFilter.createMonochromeFilter(filterId: UUID(), displayName: "", inputColor: CIColor(cgColor: UIColor.systemBlue.cgColor), inputIntensity: 1.0)
        case .CIColorPosterize:
            filter = CameraFilter.createPosterizeFilter(filterId: UUID(), displayName: "", inputLevels: 6.0)
        case .CIBoxBlur:
            filter = CameraFilter.createBlurFilter(filterId: UUID(), displayName: "", inputRadius: 10.0)
        }
        
        let response = CreateFilter.FetchProperties.Response(defaultFilter: filter)
        presenter?.presentFetchedProperties(response: response)
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
        
        let response = CreateFilter.ApplyFilter.Response(filter: filter)
        self.presenter?.presentFilterAppliedImage(response: response)
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
        
        guard let filter = filter else { return }
        
        filtersWorker.createFilter(filterToCreate: filter) { [weak self] filter in
            guard let self = self else { return }
            
            let response = CreateFilter.CreateFilter.Response(filter: filter)
            self.presenter?.presentCreatedFilter(response: response)
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
        
        guard let filterToUpdate = filterToUpdate else { return }
        
        filtersWorker.updateFilter(filterToUpdate: filterToUpdate) { [weak self] filter in
            guard let self = self else { return }
            
            let response = CreateFilter.EditFilter.Response(filter: filter)
            self.presenter?.presentEditedFilter(response: response)
        }
    }
    
    func deleteFilter(request: CreateFilter.DeleteFilter.Request) {
        guard let filterId = self.filterId else { return }
        
        filtersWorker.deleteFilter(filterId: filterId) { [weak self] filter in
            guard let self = self else { return }
            
            let response = CreateFilter.DeleteFilter.Response(filter: filter)
            self.presenter?.presentDeletedFilter(response: response)
        }
    }
    
    //MARK: - private methods
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
