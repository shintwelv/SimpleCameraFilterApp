//
//  CreateFilterPresenter.swift
//  CameraFilterApp
//
//  Created by ShinIl Heo on 12/2/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit
import RxSwift

protocol CreateFilterPresentationLogic
{
    func presentFetchedFilter(response: CreateFilter.FetchFilter.Response)
    func presentFetchedCategories(response: CreateFilter.FetchFilterCategories.Response)
    func presentFetchedProperties(response: CreateFilter.FetchProperties.Response)
    func presentFilterAppliedImage(response: CreateFilter.ApplyFilter.Response)
    func presentCreatedFilter(response: CreateFilter.CreateFilter.Response)
    func presentEditedFilter(response: CreateFilter.EditFilter.Response)
    func presentDeletedFilter(response: CreateFilter.DeleteFilter.Response)
    
//    var cameraFilter: PublishSubject<> {get}
}

class CreateFilterPresenter: CreateFilterPresentationLogic
{
    weak var viewController: CreateFilterDisplayLogic?
    
    let baseSampleImage: UIImage? = UIImage(named: "lena_color")
    
    //MARK: - Present CRUD operation result
    func presentFetchedFilter(response: CreateFilter.FetchFilter.Response) {
        if let filter = response.filter {
            sendFilterInfo(filter: filter, operation: .fetch)
        } else {
            self.viewController?.filterResult.onNext(CreateFilter.FilterInfoResult.Fail(error: .cannotFetch("필터 정보를 가져올 수 없습니다")))
        }
    }
    
    func presentFetchedCategories(response: CreateFilter.FetchFilterCategories.Response) {
        let filterCategories = response.filterCategories.map { $0.rawValue }
        self.viewController?.filterCategories.onNext(filterCategories)
    }
    
    func presentFetchedProperties(response: CreateFilter.FetchProperties.Response) {
        if let filter = response.defaultFilter {
            sendFilterInfo(filter: filter, operation: .fetch)
        } else {
            self.viewController?.filterResult.onNext(CreateFilter.FilterInfoResult.Fail(error: .cannotFetch("필터 정보를 가져올 수 없습니다")))
        }
    }
    
    func presentFilterAppliedImage(response: CreateFilter.ApplyFilter.Response) {
        if let filter = response.filter {
            sendFilterInfo(filter: filter, operation: .fetch)
        } else {
            self.viewController?.filterResult.onNext(CreateFilter.FilterInfoResult.Fail(error: .cannotFetch("필터를 적용할 수 없습니다")))
        }
    }
    
    func presentCreatedFilter(response: CreateFilter.CreateFilter.Response) {
        if let filter = response.filter {
            sendFilterInfo(filter: filter, operation: .create)
        } else {
            self.viewController?.filterResult.onNext(CreateFilter.FilterInfoResult.Fail(error: .cannotFetch("필터를 생성할 수 없습니다")))
        }
    }
    
    func presentEditedFilter(response: CreateFilter.EditFilter.Response) {
        if let filter = response.filter {
            sendFilterInfo(filter: filter, operation: .edit)
        } else {
            self.viewController?.filterResult.onNext(CreateFilter.FilterInfoResult.Fail(error: .cannotFetch("필터를 수정할 수 없습니다")))
        }
    }
    
    func presentDeletedFilter(response: CreateFilter.DeleteFilter.Response) {
        if let filter = response.filter {
            sendFilterInfo(filter: filter, operation: .edit)
        } else {
            self.viewController?.filterResult.onNext(CreateFilter.FilterInfoResult.Fail(error: .cannotFetch("필터를 삭제할 수 없습니다")))
        }
    }
    
    //MARK: - Private methods
    private func sendFilterInfo(filter: CameraFilter, operation: CreateFilter.FilterOperation) {
        var filterInfo = convertToFilterInfo(filter)
        
        guard let baseSampleImage = self.baseSampleImage else {
            self.viewController?.filterResult.onNext(CreateFilter.FilterInfoResult.Fail(error: .cannotFetch("기본 이미지가 존재하지 않습니다")))
            self.viewController?.filterResult.onNext(CreateFilter.FilterInfoResult.Success(operation: operation, result: filterInfo))
            return
        }
        
        let ciFilter = filter.ciFilter
        ciFilter.setValue(CIImage(image: baseSampleImage), forKey: kCIInputImageKey)
        
        guard let outputImage = ciFilter.outputImage else {
            self.viewController?.filterResult.onNext(CreateFilter.FilterInfoResult.Fail(error: .cannotFetch("필터를 적용할 수 없습니다")))
            return
        }
        
        filterInfo.sampleImage = UIImage(ciImage: outputImage)
        self.viewController?.filterResult.onNext(CreateFilter.FilterInfoResult.Success(operation: operation, result: filterInfo))
    }
    
    private func convertToFilterInfo(_ filter: CameraFilter) -> CreateFilter.FilterInfo {
        
        let inputColor: UIColor? = filter.inputColor != nil ? UIColor(ciColor: filter.inputColor!) : nil
        let inputIntensity: CreateFilter.FilterProperty? = filter.inputIntensity != nil ? (min: 0.0, max: 1.0, value: filter.inputIntensity!) : nil
        let inputRadius: CreateFilter.FilterProperty? = filter.inputRadius != nil ? (min: 0.0, max: 20.0, value: filter.inputRadius!) : nil
        let inputLevels: CreateFilter.FilterProperty? = filter.inputLevels != nil ? (min: 5.0, max: 10.0, value: filter.inputLevels!) : nil
        
        return CreateFilter.FilterInfo(sampleImage: self.baseSampleImage,
                                       filterName: filter.displayName,
                                       filterSystemName: filter.systemName,
                                       inputColor: inputColor,
                                       inputIntensity: inputIntensity,
                                       inputRadius: inputRadius,
                                       inputLevels: inputLevels)
    }
}
