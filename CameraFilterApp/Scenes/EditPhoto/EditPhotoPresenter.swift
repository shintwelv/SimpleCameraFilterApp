//
//  EditPhotoPresenter.swift
//  CameraFilterApp
//
//  Created by siheo on 12/15/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

protocol EditPhotoPresentationLogic
{
    func presentFetchedPhoto(response: EditPhoto.FetchPhoto.Response)
    func presentFetchedFilters(response: EditPhoto.FetchFilters.Response)
    func presentFilterAppliedImage(response: EditPhoto.ApplyFilter.Response)
    func presentSavePhotoResult(response: EditPhoto.SavePhoto.Response)
}

class EditPhotoPresenter: EditPhotoPresentationLogic
{
    weak var viewController: EditPhotoDisplayLogic?
    
    private var sampleImage: UIImage = UIImage(named: "lena_color")!
    
    // MARK: EditPhotoPresentationLogic
    
    func presentFetchedPhoto(response: EditPhoto.FetchPhoto.Response) {
        let photo = response.photo
        
        let viewModel = EditPhoto.FetchPhoto.ViewModel(photo: photo)
        self.viewController?.displayFetchedPhoto(viewModel: viewModel)
    }
    
    func presentFetchedFilters(response: EditPhoto.FetchFilters.Response) {
        let filters = response.cameraFilters
        
        let filterInfos: [EditPhoto.FilterInfo] = filters.map { filter in
            let filterId = filter.filterId
            let filterName = filter.displayName
            
            filter.ciFilter.setValue(CIImage(image: self.sampleImage), forKey: kCIInputImageKey)
            let filterAppliedImage = UIImage(ciImage: filter.ciFilter.outputImage!)
            return EditPhoto.FilterInfo(filterId: filterId, filterName: filterName, sampleImage: filterAppliedImage)
        }
        
        let viewModel = EditPhoto.FetchFilters.ViewModel(filterInfos: filterInfos)
        self.viewController?.displayFetchedFilters(viewModel: viewModel)
    }
    
    func presentFilterAppliedImage(response: EditPhoto.ApplyFilter.Response) {
        let photo = response.photo

        if let filter = response.cameraFilter {
            
            let ciFilter = filter.ciFilter
            
            ciFilter.setValue(CIImage(image: photo), forKey: kCIInputImageKey)
            
            guard let ciImage: CIImage = ciFilter.outputImage else {
                let viewModel = EditPhoto.ApplyFilter.ViewModel(filterAppliedPhoto: photo)
                self.viewController?.displayFilterAppliedImage(viewModel: viewModel)
                return
            }
            
            let filterAppliedImage: UIImage = UIImage(ciImage: ciImage, scale: photo.scale, orientation: photo.imageOrientation)
            
            let viewModel = EditPhoto.ApplyFilter.ViewModel(filterAppliedPhoto: filterAppliedImage)
            self.viewController?.displayFilterAppliedImage(viewModel: viewModel)
        } else {
            let viewModel = EditPhoto.ApplyFilter.ViewModel(filterAppliedPhoto: photo)
            self.viewController?.displayFilterAppliedImage(viewModel: viewModel)
        }
    }
    
    func presentSavePhotoResult(response: EditPhoto.SavePhoto.Response) {
        let savePhotoResult = response.savePhotoResult
        let viewModel = EditPhoto.SavePhoto.ViewModel(savePhotoResult: savePhotoResult)
        self.viewController?.displayPhotoSaveResult(viewModel: viewModel)
    }
}
