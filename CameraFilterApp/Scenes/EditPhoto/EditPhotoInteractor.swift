//
//  EditPhotoInteractor.swift
//  CameraFilterApp
//
//  Created by siheo on 12/15/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit
import RxSwift

protocol EditPhotoBusinessLogic
{
    func fetchFilters(request: EditPhoto.FetchFilters.Request)
    func applyFilter(request: EditPhoto.ApplyFilter.Request)
    func savePhoto(request: EditPhoto.SavePhoto.Request)
}

protocol EditPhotoDataStore
{
    var photo: UIImage? { get set }
}

class EditPhotoInteractor: EditPhotoBusinessLogic, EditPhotoDataStore
{
    var presenter: EditPhotoPresentationLogic?
    var worker = EditPhotoWorker()
    
    private var filtersWorker: FiltersWorker = FiltersWorker(filtersStore: FilterMemStore())
    
    var photo: UIImage?
    
    init() {
        configureBinding()
    }
    
    private let bag = DisposeBag()
    
    private lazy var fetchedFilter: Observable<FiltersWorker.OperationResult<CameraFilter>> = {
        self.filtersWorker.filter.filter {
            switch $0 {
            case .Success(let operation, _) where operation == .fetch: return true
            case .Failure(let error) where error == .cannotFetch(error.localizedDescription): return true
            default: return false
            }
        }
    }()
    
    private func configureBinding() {
        self.filtersWorker.filters.map { (result) -> [CameraFilter] in
            switch result {
            case .Success(let operation, let filters) where operation == .fetch: return filters
            default: return []
            }
        }.subscribe(
            onNext: { [weak self] filters in
                guard let self = self else { return }
            
                let response = EditPhoto.FetchFilters.Response(cameraFilters: filters)                
            }
        ).disposed(by: self.bag)
        
        self.fetchedFilter.map { (result) -> CameraFilter? in
            switch result {
            case .Success(_, let filter): return filter
            case .Failure(_): return nil
            }
        }.subscribe(
            onNext: { [weak self] filter in
                guard let self = self,
                    let photo = photo else { return }
                
                let response = EditPhoto.ApplyFilter.Response(photo: photo, cameraFilter: filter)
            }
        ).disposed(by: self.bag)
        
        self.worker.savePhotoResult.subscribe(
            onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .Success(_):
                    let response = EditPhoto.SavePhoto.Response(savePhotoResult: result)
                case .Failure(let error):
                    switch error {
                    case .cannotConvert(let message):
                        let response = EditPhoto.SavePhoto.Response(savePhotoResult: .Failure(.cannotConvert("이미지를 저장하지 못했습니다")))
                    case .cannotSave(let message):
                        let response = EditPhoto.SavePhoto.Response(savePhotoResult: .Failure(.cannotSave("이미지를 저장하지 못했습니다")))
                    case .noCIImage(let message):
                        let response = EditPhoto.SavePhoto.Response(savePhotoResult: .Failure(.noCIImage("이미지를 저장하지 못했습니다")))
                    }
                    break
                }
            }
        ).disposed(by: self.bag)
    }
    
    // MARK: EditPhotoBusinessLogic
    func fetchFilters(request: EditPhoto.FetchFilters.Request) {
        filtersWorker.fetchFilters()
    }
    
    func applyFilter(request: EditPhoto.ApplyFilter.Request) {
        let filterId = request.filterId
        filtersWorker.fetchFilter(filterId: filterId)
    }
    
    func savePhoto(request: EditPhoto.SavePhoto.Request) {
        let filterAppliedPhoto = request.filterAppliedPhoto
        self.worker.savePhoto(filterAppliedPhoto)
    }
}
