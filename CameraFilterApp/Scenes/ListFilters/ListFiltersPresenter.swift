//
//  ListFiltersPresenter.swift
//  CameraFilterApp
//
//  Created by siheo on 11/30/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

protocol ListFiltersPresentationLogic
{
    func displayFilters(response: ListFilters.FetchFilters.Response)
}

class ListFiltersPresenter: ListFiltersPresentationLogic
{
    weak var viewController: ListFiltersDisplayLogic?
    
    lazy var sampleImage: UIImage = UIImage(named: "lena_color")!
    
    func displayFilters(response: ListFilters.FetchFilters.Response) {
        let filters = response.filters
        
        let filterInfos: [ListFilters.FilterInfo] = filters.map { filter in
            let filterId = filter.filterId
            let filterName = filter.displayName

            filter.ciFilter.setValue(self.sampleImage.ciImage!, forKey: kCIInputImageKey)
            let filterAppliedImage = UIImage(ciImage: filter.ciFilter.outputImage!)
            
            return ListFilters.FilterInfo(filterId: filterId, filterName: filterName, filterAppliedImage: filterAppliedImage)
        }
        
        let viewModel = ListFilters.FetchFilters.ViewModel(filterInfos: filterInfos)
        viewController?.displayFetchedFilters(viewModel: viewModel)
    }
}
