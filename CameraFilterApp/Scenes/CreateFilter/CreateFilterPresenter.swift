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
    var isEditingFilter: BehaviorSubject<Bool> { get }
    var filterCategories: BehaviorSubject<[CameraFilter.FilterName]> { get }
    var cameraFilterResult: PublishSubject<CreateFilter.CameraFilterResult> { get }
}

class CreateFilterPresenter: CreateFilterPresentationLogic
{
    weak var viewController: CreateFilterDisplayLogic?
    
    let baseSampleImage: UIImage? = UIImage(named: "lena_color")
    
    init() {
        configureBinding()
    }
    
    let bag = DisposeBag()
    
    var isEditingFilter = BehaviorSubject<Bool>(value: false)
    var filterCategories = BehaviorSubject<[CameraFilter.FilterName]>(value: [])
    var cameraFilterResult = PublishSubject<CreateFilter.CameraFilterResult>()
    
    lazy var cameraFilter: Observable<(CreateFilter.FilterOperation, CameraFilter)> = {
        self.cameraFilterResult.map { filterResult in
            switch filterResult {
            case .Success(let operation, let cameraFilter):
                return (operation, cameraFilter)
            case .Fail(_):
                return nil
            }
        }.compactMap { $0 }
    }()
    
    lazy var filterError: Observable<CreateFilter.FilterError> = {
        self.cameraFilterResult.map { result in
            switch result{
            case .Success(_, _):
                return nil
            case .Fail(let error):
                return error
            }
        }.compactMap { $0 }
    }()
    
    private func configureBinding() {
        self.isEditingFilter.subscribe(
            onNext: { [weak self] isEditing in
                self?.viewController?.isEditingFilter.onNext(isEditing)
            }
        ).disposed(by: self.bag)
        
        self.filterCategories.subscribe(
            onNext: { [weak self] filterCategories in
                let systemNames: [String] = filterCategories.map{ $0.rawValue }
                self?.viewController?.filterCategories.onNext(systemNames)
            }
        ).disposed(by: self.bag)
        
        self.cameraFilter.subscribe(
            onNext: { [weak self] (operation, cameraFilter) in
                self?.sendFilterInfo(filter: cameraFilter, operation: operation)
            }
        ).disposed(by: self.bag)
        
        self.filterError.subscribe(
            onNext: { [weak self] error in
                self?.viewController?.filterResult.onNext(CreateFilter.FilterInfoResult.Fail(error: error))
            }
        ).disposed(by: self.bag)
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
