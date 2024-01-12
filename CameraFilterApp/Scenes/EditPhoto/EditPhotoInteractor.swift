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
    func fetchPhoto(request: EditPhoto.FetchPhoto.Request)
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
    
    private var filtersWorker: FiltersWorker = FiltersWorker(remoteStore: FilterFirebaseStore(), localStore: FilterMemStore())
    private var userWorker: UserWorker = UserWorker(store: UserFirebaseStore(), authentication: FirebaseAuthentication())
    
    var photo: UIImage?
    
    init() {
        configureBinding()
    }
    
    private let bag = DisposeBag()
    
    private func configureBinding() {
        self.worker.savePhotoResult.subscribe(
            onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .Success(_):
                    let response = EditPhoto.SavePhoto.Response(savePhotoResult: result)
                    self.presenter?.presentSavePhotoResult(response: response)
                case .Failure(let error):
                    switch error {
                    case .cannotConvert(let message):
                        print("cannotConvert error: \(message)")
                        let response = EditPhoto.SavePhoto.Response(savePhotoResult: .Failure(.cannotConvert("이미지를 저장하지 못했습니다")))
                        self.presenter?.presentSavePhotoResult(response: response)
                    case .cannotSave(let message):
                        print("cannotSave error: \(message)")
                        let response = EditPhoto.SavePhoto.Response(savePhotoResult: .Failure(.cannotSave("이미지를 저장하지 못했습니다")))
                        self.presenter?.presentSavePhotoResult(response: response)
                    case .noCIImage(let message):
                        print("noCIImage error: \(message)")
                        let response = EditPhoto.SavePhoto.Response(savePhotoResult: .Failure(.noCIImage("이미지를 저장하지 못했습니다")))
                        self.presenter?.presentSavePhotoResult(response: response)
                    }
                }
            }
        ).disposed(by: self.bag)
    }
    
    // MARK: EditPhotoBusinessLogic
    func fetchPhoto(request: EditPhoto.FetchPhoto.Request) {
        guard let photo = self.photo else { return }
        
        let response = EditPhoto.FetchPhoto.Response(photo: photo)
        self.presenter?.presentFetchedPhoto(response: response)
    }
    
    func fetchFilters(request: EditPhoto.FetchFilters.Request) {
        userWorker.fetchCurrentlyLoggedInUser()
            .subscribe(
                onNext: { [weak self] user in
                    guard let self = self else { return }
                    
                    self.filtersWorker.fetchFilters(user: user)
                        .subscribe(
                            onNext: { filters in
                                self.presentFetchedFilters(filters: filters)
                            },
                            onError: { error in
                                print(error)
                                self.presentFetchedFilters(filters: [])
                            }
                        )
                        .disposed(by: self.bag)
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    
                    print(error)
                    self.presentFetchedFilters(filters: [])
                }
            )
            .disposed(by: self.bag)
    }
    
    func applyFilter(request: EditPhoto.ApplyFilter.Request) {
        let filterId = request.filterId
        
        userWorker.fetchCurrentlyLoggedInUser()
            .subscribe(
                onNext: { [weak self] user in
                    guard let self = self else { return }
                    self.filtersWorker.fetchFilter(user: user, filterId: filterId)
                        .subscribe(
                            onNext: { filter in
                                self.presentAppliedPhoto(filter: filter)
                            },
                            onError: { error in
                                print(error)
                                self.presentAppliedPhoto(filter: nil)
                            }
                        )
                        .disposed(by: self.bag)
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    
                    print(error)
                    self.presentAppliedPhoto(filter: nil)
                }
            )
            .disposed(by: self.bag)
    }
    
    func savePhoto(request: EditPhoto.SavePhoto.Request) {
        let filterAppliedPhoto = request.filterAppliedPhoto
        self.worker.savePhoto(filterAppliedPhoto)
    }
    
    //MARK: - Private methods
    private func presentFetchedFilters(filters: [CameraFilter]) {
        let response = EditPhoto.FetchFilters.Response(cameraFilters: filters)
        self.presenter?.presentFetchedFilters(response: response)
    }

    private func presentAppliedPhoto(filter: CameraFilter?) {
        guard let photo = photo else { return }
        
        let response = EditPhoto.ApplyFilter.Response(photo: photo, cameraFilter: filter)
        self.presenter?.presentFilterAppliedImage(response: response)
    }
}
