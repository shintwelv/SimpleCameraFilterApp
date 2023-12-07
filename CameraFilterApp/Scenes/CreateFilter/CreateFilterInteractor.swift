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
            filtersWorker.fetchFilter(filterId: filterId) { filter in
                guard let filter = filter else {
                    let response = CreateFilter.FetchFilter.Response(filter: nil)
                    self.presenter?.presentFetchedFilter(response: response)
                    return
                }
                
                let response = CreateFilter.FetchFilter.Response(filter: filter)
                self.presenter?.presentFetchedFilter(response: response)
            }
        } else {
            let response = CreateFilter.FetchFilter.Response(filter: nil)
            self.presenter?.presentFetchedFilter(response: response)
        }
    }
    
    func fetchFilterCategories(request: CreateFilter.FetchFilterCategories.Request) {
        let filterCategories: [CameraFilter.FilterName] = CameraFilter.FilterName.allCases
        
        let response = CreateFilter.FetchFilterCategories.Response(filterCategories: filterCategories)
        presenter?.presentFetchedCategories(response: response)
    }
    
    func fetchProperties(request: CreateFilter.FetchProperties.Request) {
        let filterSystemName = request.filterSystemName
        
        var response: CreateFilter.FetchProperties.Response
        switch filterSystemName {
        case .CIColorMonochrome:
            response = CreateFilter.FetchProperties.Response(inputColor: .systemBlue,
                                                             inputIntensity: (min: 0.0, max: 1.0, value: 1.0),
                                                             inputRadius: nil,
                                                             inputLevels: nil)
        case .CIColorPosterize:
            response = CreateFilter.FetchProperties.Response(inputColor: nil,
                                                             inputIntensity: nil,
                                                             inputRadius: nil,
                                                             inputLevels: (min: 0.0, max: 10.0, value: 6.0))
        case .CIBoxBlur:
            response = CreateFilter.FetchProperties.Response(inputColor: nil,
                                                             inputIntensity: nil,
                                                             inputRadius: (min: 0.0, max: 20.0, value: 10.0),
                                                             inputLevels: nil)
        default:
            response = CreateFilter.FetchProperties.Response(inputColor: nil,
                                                             inputIntensity: nil,
                                                             inputRadius: nil,
                                                             inputLevels: nil)
        }
        
        presenter?.presentFetchedProperties(response: response)
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
        
        filtersWorker.createFilter(filterToCreate: filter) { filter in
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
        
        filtersWorker.updateFilter(filterToUpdate: filterToUpdate) { filter in
            let response = CreateFilter.EditFilter.Response(filter: filter)
            self.presenter?.presentEditedFilter(response: response)
        }
    }
    
    func deleteFilter(request: CreateFilter.DeleteFilter.Request) {
        guard let filterId = self.filterId else { return }
        
        filtersWorker.deleteFilter(filterId: filterId) { filter in
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
            
            return CameraFilter.createMonochromeFilter(filterId: filterId, displayName: displayName, inputColor: inputColor.ciColor, inputIntensity: inputIntensity)
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
