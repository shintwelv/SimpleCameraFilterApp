//
//  CreateFilterInteractor.swift
//  CameraFilterApp
//
//  Created by ShinIl Heo on 12/2/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit
import RxSwift

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
    var filtersWorker: FiltersWorker = FiltersWorker(remoteStore: FilterFirebaseStore(), localStore: FilterMemStore())
    var authenticationWorker: UserAuthenticationWorker = UserAuthenticationWorker(provider: FirebaseAuthentication())
    
    var filterId: UUID?
    
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
    
    private lazy var createdFilter: Observable<FiltersWorker.OperationResult<CameraFilter>> = {
        self.filtersWorker.filter.filter {
            switch $0 {
            case .Success(let operation, _) where operation == .create: return true
            case .Failure(let error) where error == .cannotCreate(error.localizedDescription): return true
            default: return false
            }
        }
    }()
    
    private lazy var editedFilter: Observable<FiltersWorker.OperationResult<CameraFilter>> = {
        self.filtersWorker.filter.filter {
            switch $0 {
            case .Success(let operation, _) where operation == .update: return true
            case .Failure(let error) where error == .cannotUpdate(error.localizedDescription): return true
            default: return false
            }
        }
    }()
    
    private lazy var deletedFilter: Observable<FiltersWorker.OperationResult<CameraFilter>> = {
        self.filtersWorker.filter.filter {
            switch $0 {
            case .Success(let operation, _) where operation == .delete: return true
            case .Failure(let error) where error == .cannotDelete(error.localizedDescription): return true
            default: return false
            }
        }
    }()
    
    private func configureBinding() {
        self.fetchedFilter.map { (result) -> CameraFilter? in
            switch result {
            case .Success(_, let filter): return filter
            case .Failure(_): return nil
            }
        }.subscribe(
            onNext: { [weak self] filter in
                guard let self = self else { return }
                
                let response = CreateFilter.FetchFilter.Response(filter: filter)
                self.presenter?.presentFetchedFilter(response: response)
            }
        ).disposed(by: self.bag)
        
        self.createdFilter.map { (result) -> CameraFilter? in
            switch result {
            case .Success(_, let filter): return filter
            case .Failure(_): return nil
            }
        }.subscribe(
            onNext: { [weak self] filter in
                guard let self = self else { return }
                
                let response = CreateFilter.CreateFilter.Response(filter: filter)
                self.presenter?.presentCreatedFilter(response: response)
            }
        ).disposed(by: self.bag)
        
        self.editedFilter.map { (result) -> CameraFilter? in
            switch result {
            case .Success(_, let filter): return filter
            case .Failure(_): return nil
            }
        }.subscribe(
            onNext: { [weak self] filter in
                guard let self = self else { return }
                
                let response = CreateFilter.EditFilter.Response(filter: filter)
                self.presenter?.presentEditedFilter(response: response)
            }
        ).disposed(by: self.bag)
        
        self.deletedFilter.map { (result) -> CameraFilter? in
            switch result {
            case .Success(_, let filter): return filter
            case .Failure(_): return nil
            }
        }.subscribe(
            onNext: { [weak self] filter in
                guard let self = self else { return }
                
                let response = CreateFilter.DeleteFilter.Response(filter: filter)
                self.presenter?.presentDeletedFilter(response: response)
            }
        ).disposed(by: self.bag)
    }
    
    // MARK: CRUD operations
    func fetchFilter(request: CreateFilter.FetchFilter.Request) {
        if let filterId = self.filterId {
            authenticationWorker.loggedInUser { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .Success(let user):
                    self.filtersWorker.fetchFilter(user:user, filterId: filterId)
                case .Failure(let error):
                    print(error)
                    let response = CreateFilter.FetchFilter.Response(filter: nil)
                    self.presenter?.presentFetchedFilter(response: response)
                }
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
        
        let filterToCreate: CameraFilter? = createFilter(filterId: UUID(),
                                                 displayName: filterName,
                                                 systemName: filterSystemName,
                                                 inputColor: inputColor,
                                                 inputIntensity: inputIntensity, 
                                                 inputRadius: inputRadius,
                                                 inputLevels: inputLevels)
        
        if let filterToCreate = filterToCreate {
            authenticationWorker.loggedInUser { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .Success(let user):
                    self.filtersWorker.createFilter(user:user, filterToCreate: filterToCreate)
                case .Failure(let error):
                    print(error)
                    let response = CreateFilter.EditFilter.Response(filter: nil)
                    self.presenter?.presentEditedFilter(response: response)
                }
            }
        } else {
            let response = CreateFilter.EditFilter.Response(filter: nil)
            self.presenter?.presentEditedFilter(response: response)
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
        
        if let filterToUpdate = filterToUpdate {
            authenticationWorker.loggedInUser { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .Success(let user):
                    self.filtersWorker.updateFilter(user:user, filterToUpdate: filterToUpdate)
                case .Failure(let error):
                    print(error)
                    let response = CreateFilter.EditFilter.Response(filter: nil)
                    self.presenter?.presentEditedFilter(response: response)
                }
            }
        } else {
            let response = CreateFilter.EditFilter.Response(filter: nil)
            self.presenter?.presentEditedFilter(response: response)
        }
    }
    
    func deleteFilter(request: CreateFilter.DeleteFilter.Request) {
        if let filterId = self.filterId {
            authenticationWorker.loggedInUser { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .Success(let user):
                    self.filtersWorker.deleteFilter(user:user, filterId: filterId)
                case .Failure(let error):
                    print(error)
                    let response = CreateFilter.DeleteFilter.Response(filter: nil)
                    self.presenter?.presentDeletedFilter(response: response)
                }
            }
        } else {
            let response = CreateFilter.DeleteFilter.Response(filter: nil)
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
