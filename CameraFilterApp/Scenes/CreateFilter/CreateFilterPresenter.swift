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
    func presentFilterAppliedImage(response: CreateFilter.ApplyFilter.Response)
    func presentCreatedFilter(response: CreateFilter.CreateFilter.Response)
    func presentEditedFilter(response: CreateFilter.EditFilter.Response)
    func presentDeletedFilter(response: CreateFilter.DeleteFilter.Response)
}

class CreateFilterPresenter: CreateFilterPresentationLogic
{
    weak var viewController: CreateFilterDisplayLogic?
    
    let baseSampleImage: UIImage? = UIImage(named: "lena_color")
    
    //MARK: - Present CRUD operation result
    func presentFetchedFilter(response: CreateFilter.FetchFilter.Response) {
        self.viewController?.sampleImage.onNext(baseSampleImage)

        if let filter = response.filter {
            let filterInfo = convertToFilterInfo(filter)
            
            self.viewController?.filterName.onNext(filterInfo.filterName)
            self.viewController?.filterSystemName.onNext(filterInfo.filterSystemName)
            self.viewController?.inputColor.onNext(filterInfo.inputColor)
            self.viewController?.inputIntensity.onNext(filterInfo.inputIntensity)
            self.viewController?.inputRadius.onNext(filterInfo.inputRadius)
            self.viewController?.inputLevels.onNext(filterInfo.inputLevels)
            
            guard let baseSampleImage = self.baseSampleImage else { return }
            
            let ciFilter = filter.ciFilter
            ciFilter.setValue(CIImage(image: baseSampleImage), forKey: kCIInputImageKey)
            
            guard let outputImage = ciFilter.outputImage else { return }

            self.viewController?.sampleImage.onNext(UIImage(ciImage: outputImage))
        } else {
            self.viewController?.filterName.onNext(nil)
            self.viewController?.filterSystemName.onNext(nil)
            self.viewController?.inputColor.onNext(nil)
            self.viewController?.inputIntensity.onNext(nil)
            self.viewController?.inputRadius.onNext(nil)
            self.viewController?.inputLevels.onNext(nil)
        }
    }
    
    func presentFetchedCategories(response: CreateFilter.FetchFilterCategories.Response) {
        let filterCategories = response.filterCategories.map { $0.rawValue }
        self.viewController?.filterCategories.onNext(filterCategories)
    }
    
    func presentFetchedProperties(response: CreateFilter.FetchProperties.Response) {
        self.viewController?.inputColor.onNext(response.inputColor)
        self.viewController?.inputIntensity.onNext(response.inputIntensity)
        self.viewController?.inputRadius.onNext(response.inputRadius)
        self.viewController?.inputLevels.onNext(response.inputLevels)
    }
    
    func presentFilterAppliedImage(response: CreateFilter.ApplyFilter.Response) {
        self.viewController?.sampleImage.onNext(self.baseSampleImage)
        
        guard let filter = response.filter,
              let baseSampleImage = self.baseSampleImage else { return }
        
        filter.ciFilter.setValue(CIImage(image: baseSampleImage), forKey: kCIInputImageKey)
        
        guard let outputImage = filter.ciFilter.outputImage else { return }
        self.viewController?.sampleImage.onNext(UIImage(ciImage: outputImage))
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
