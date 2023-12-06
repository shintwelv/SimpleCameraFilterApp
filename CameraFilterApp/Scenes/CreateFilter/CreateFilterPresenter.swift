//
//  CreateFilterPresenter.swift
//  CameraFilterApp
//
//  Created by ShinIl Heo on 12/2/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

protocol CreateFilterPresentationLogic
{
    func presentFetchedFilter(response: CreateFilter.FetchFilter.Response)
    func presentFetchedCategories(response: CreateFilter.FetchFilterCategories.Response)
    func presentFetchedProperties(response: CreateFilter.FetchProperties.Response)
    func presentCreatedFilter(response: CreateFilter.CreateFilter.Response)
    func presentEditedFilter(response: CreateFilter.EditFilter.Response)
    func presentDeletedFilter(response: CreateFilter.DeleteFilter.Response)
}

class CreateFilterPresenter: CreateFilterPresentationLogic
{
    weak var viewController: CreateFilterDisplayLogic?
    
    //MARK: - Present CRUD operation result
    func presentFetchedFilter(response: CreateFilter.FetchFilter.Response) {
        if let filter = response.filter {
            let filterInfo = convertToFilterInfo(filter)
            
            let viewModel = CreateFilter.FetchFilter.ViewModel(filterInfo: filterInfo)
            self.viewController?.displayFetchedFilter(viewModel: viewModel)
        } else {
            let viewModel = CreateFilter.FetchFilter.ViewModel(filterInfo: nil)
            self.viewController?.displayFetchedFilter(viewModel: viewModel)
        }
    }
    
    func presentFetchedCategories(response: CreateFilter.FetchFilterCategories.Response) {
        let filterCategories = response.filterCategories.map { $0.rawValue }
        
        let viewModel = CreateFilter.FetchFilterCategories.ViewModel(filterCategories: filterCategories)
        self.viewController?.displayFetchedCategories(viewModel: viewModel)
    }
    
    func presentFetchedProperties(response: CreateFilter.FetchProperties.Response) {
        let viewModel = CreateFilter.FetchProperties.ViewModel(inputColor: response.inputColor,
                                                               inputIntensity: response.inputIntensity,
                                                               inputRadius: response.inputRadius,
                                                               inputLevels: response.inputLevels)
        self.viewController?.displayFetchedProperties(viewModel: viewModel)
    }
    
    func presentCreatedFilter(response: CreateFilter.CreateFilter.Response) {
        if let filter = response.filter {
            let filterInfo = convertToFilterInfo(filter)
            
            let viewModel = CreateFilter.CreateFilter.ViewModel(filterInfo: filterInfo)
            self.viewController?.displayCreatedFilter(viewModel: viewModel)
        } else {
            let viewModel = CreateFilter.CreateFilter.ViewModel(filterInfo: nil)
            self.viewController?.displayCreatedFilter(viewModel: viewModel)
        }
    }
    
    func presentEditedFilter(response: CreateFilter.EditFilter.Response) {
        if let filter = response.filter {
            let filterInfo = convertToFilterInfo(filter)
            
            let viewModel = CreateFilter.EditFilter.ViewModel(filterInfo: filterInfo)
            self.viewController?.displayEditedFilter(viewModel: viewModel)
        } else {
            let viewModel = CreateFilter.EditFilter.ViewModel(filterInfo: nil)
            self.viewController?.displayEditedFilter(viewModel: viewModel)
        }
    }
    
    func presentDeletedFilter(response: CreateFilter.DeleteFilter.Response) {
        if let filter = response.filter {
            let filterInfo = convertToFilterInfo(filter)
            
            let viewModel = CreateFilter.DeleteFilter.ViewModel(filterInfo: filterInfo)
            self.viewController?.displayDeletedFilter(viewModel: viewModel)
        } else {
            let viewModel = CreateFilter.DeleteFilter.ViewModel(filterInfo: nil)
            self.viewController?.displayDeletedFilter(viewModel: viewModel)
        }
    }
    
    //MARK: - Private methods
    private func convertToFilterInfo(_ filter: CameraFilter) -> CreateFilter.FilterInfo {
        
        let inputColor: UIColor? = filter.inputColor != nil ? UIColor(ciColor: filter.inputColor!) : nil
        let inputIntensity: CreateFilter.FilterProperty? = filter.inputIntensity != nil ? (min: 0.0, max: 1.0, value: filter.inputIntensity!) : nil
        let inputRadius: CreateFilter.FilterProperty? = filter.inputRadius != nil ? (min: 0.0, max: 20.0, value: filter.inputRadius!) : nil
        let inputLevels: CreateFilter.FilterProperty? = filter.inputLevels != nil ? (min: 0.0, max: 10.0, value: filter.inputLevels!) : nil
        
        return CreateFilter.FilterInfo(filterName: filter.displayName,
                                       filterSystemName: filter.systemName,
                                       inputColor: inputColor,
                                       inputIntensity: inputIntensity,
                                       inputRadius: inputRadius,
                                       inputLevels: inputLevels)
    }
}
