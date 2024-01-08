//
//  EditPhotoViewController.swift
//  CameraFilterApp
//
//  Created by siheo on 12/15/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

protocol EditPhotoDisplayLogic: AnyObject
{
    func displayFetchedPhoto(viewModel: EditPhoto.FetchPhoto.ViewModel)
    func displayFetchedFilters(viewModel: EditPhoto.FetchFilters.ViewModel)
    func displayFilterAppliedImage(viewModel: EditPhoto.ApplyFilter.ViewModel)
    func displayPhotoSaveResult(viewModel: EditPhoto.SavePhoto.ViewModel)
}

class EditPhotoViewController: UIViewController, EditPhotoDisplayLogic
{
    var interactor: EditPhotoBusinessLogic?
    var router: (NSObjectProtocol & EditPhotoRoutingLogic & EditPhotoDataPassing)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = EditPhotoInteractor()
        let presenter = EditPhotoPresenter()
        let router = EditPhotoRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    private var photoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.filters"), for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 30
        return button
    }()
    
    private var filterCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 80)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private var buttonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.distribution = .fillEqually
        return view
    }()
    
    private var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 10
        return button
    }()
    
    private var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()
    
    private var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.backgroundColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 0.5)
        view.style = .large
        view.color = .white
        view.isHidden = true
        return view
    }()
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureUI()
        configureFiltersCollectionView()
        configureAutoLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFilters()
        fetchPhoto()
    }
    
    private func configureUI() {
        self.view.backgroundColor = .white
        
        [
            self.photoImageView,
            self.filterCollectionView,
            self.filterButton,
            self.buttonStackView,
            self.indicatorView,
        ].forEach { self.view.addSubview($0) }
        
        [
            self.cancelButton,
            self.saveButton,
        ].forEach { self.buttonStackView.addArrangedSubview($0) }
        
        self.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        self.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        self.filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
    typealias Item = EditPhoto.FilterInfo
    enum Section: CaseIterable {
        case main
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    private func configureFiltersCollectionView() {
        self.filterCollectionView.delegate = self
        
        let cellRegistration = UICollectionView.CellRegistration<EditPhotoFilterCell, EditPhoto.FilterInfo> { cell, indexPath, item in
            cell.configure(filterInfo: item)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: self.filterCollectionView, cellProvider: { collectionView, indexPath, item in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: item)
        })
    }
    
    private func configureAutoLayout() {
        [
            self.photoImageView,
            self.filterCollectionView,
            self.filterButton,
            self.buttonStackView,
            self.cancelButton,
            self.saveButton,
            self.indicatorView,
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            self.photoImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
            self.photoImageView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.7),
            self.photoImageView.heightAnchor.constraint(equalTo: self.photoImageView.widthAnchor, multiplier: 1.0),
            self.photoImageView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            
            self.filterCollectionView.topAnchor.constraint(equalTo: self.photoImageView.bottomAnchor, constant: 50),
            self.filterCollectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            self.filterCollectionView.trailingAnchor.constraint(equalTo: self.filterButton.leadingAnchor, constant: -5),
            self.filterCollectionView.heightAnchor.constraint(equalToConstant: 150),
            
            self.filterButton.widthAnchor.constraint(equalToConstant: 60),
            self.filterButton.heightAnchor.constraint(equalTo: self.filterButton.widthAnchor),
            self.filterButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            self.filterButton.centerYAnchor.constraint(equalTo: self.filterCollectionView.centerYAnchor),
            
            self.buttonStackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            self.buttonStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            self.buttonStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            self.buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            
            self.indicatorView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.indicatorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.indicatorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.indicatorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    
    private func showIndicatorView() {
        self.indicatorView.isHidden = false
        if self.indicatorView.isAnimating == false {
            self.indicatorView.startAnimating()
        }
    }
    
    private func hideIndicatorView() {
        self.indicatorView.isHidden = true
        if self.indicatorView.isAnimating == true {
            self.indicatorView.stopAnimating()
        }
    }
    
    @objc private func saveButtonTapped(_ button: UIButton) {
        guard let filterAppliedPhoto = self.photoImageView.image else { return }
        
        showIndicatorView()
        
        let request = EditPhoto.SavePhoto.Request(filterAppliedPhoto: filterAppliedPhoto)
        self.interactor?.savePhoto(request: request)
    }
    
    @objc private func cancelButtonTapped(_ button: UIButton) {
        self.router?.routeToCameraPreview(segue: nil)
    }
    
    @objc private func filterButtonTapped(_ button: UIButton) {
        self.router?.routeToListFilters(segue: nil)
    }
    
    //MARK: - EditPhotoBusinessLogic
    private func fetchFilters() {
        let request = EditPhoto.FetchFilters.Request()
        interactor?.fetchFilters(request: request)
    }
    
    private func fetchPhoto() {
        let request = EditPhoto.FetchPhoto.Request()
        interactor?.fetchPhoto(request: request)
    }
    
    //MARK: - EditPhotoDisplayLogic
    func displayFetchedPhoto(viewModel: EditPhoto.FetchPhoto.ViewModel) {
        let photo = viewModel.photo
        
        self.photoImageView.backgroundColor = .clear
        self.photoImageView.image = photo
    }
    
    func displayFetchedFilters(viewModel: EditPhoto.FetchFilters.ViewModel) {
        let filterInfos = viewModel.filterInfos

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(filterInfos, toSection: .main)
        dataSource.apply(snapshot)
    }
    
    func displayFilterAppliedImage(viewModel: EditPhoto.ApplyFilter.ViewModel) {
        let filterAppliedPhoto = viewModel.filterAppliedPhoto
        
        self.photoImageView.backgroundColor = .clear
        self.photoImageView.image = filterAppliedPhoto
    }
    
    func displayPhotoSaveResult(viewModel: EditPhoto.SavePhoto.ViewModel) {
        let savePhotoResult = viewModel.savePhotoResult
        
        var message: String = ""
        switch savePhotoResult {
        case .Success(_):
            message = "이미지가 갤러리에 저장되었습니다"
        case .Failure(let savePhotoError):
            message = "\(savePhotoError)"
        }

        let alertController = UIAlertController(title: "안내", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true)
        
        hideIndicatorView()
    }
}

extension EditPhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        let selectedFilterInfo = snapshot.itemIdentifiers[indexPath.row]
        
        let request = EditPhoto.ApplyFilter.Request(filterId: selectedFilterInfo.filterId)
        self.interactor?.applyFilter(request: request)
    }
}
