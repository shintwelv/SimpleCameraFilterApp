//
//  ListFiltersViewController.swift
//  CameraFilterApp
//
//  Created by siheo on 11/30/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit

protocol ListFiltersDisplayLogic: AnyObject
{
    func displayFetchedFilters(viewModel: ListFilters.FetchFilters.ViewModel)
}

class ListFiltersViewController: UIViewController, ListFiltersDisplayLogic
{
    var interactor: ListFiltersBusinessLogic?
    var router: (NSObjectProtocol & ListFiltersRoutingLogic & ListFiltersDataPassing)?
    
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
        let interactor = ListFiltersInteractor()
        let presenter = ListFiltersPresenter()
        let router = ListFiltersRouter()
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
    
    private var filterAddButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("추가", for: .normal)
        button.tintColor = .systemPurple
        button.titleLabel?.font = .systemFont(ofSize: 18)
        return button
    }()
    
    private var filterCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 130)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
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
    }
    
    private func configureUI() {
        self.view.backgroundColor = .white
        
        [
            self.filterAddButton,
            self.filterCollectionView,
        ].forEach { self.view.addSubview($0) }
        
        self.filterCollectionView.delegate = self
        
        self.filterAddButton.addTarget(self, action: #selector(filterAddButtonTapped), for: .touchUpInside)
        
        self.filterCollectionView.register(ListFilterCell.self, forCellWithReuseIdentifier: "listFilterCell")
    }
    
    typealias Item = ListFilters.FilterInfo
    enum Section: CaseIterable {
        case main
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    private func configureFiltersCollectionView() {
        let cellRegistration = UICollectionView.CellRegistration<ListFilterCell, ListFilters.FilterInfo> { cell, indexPath, item in
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
            self.filterAddButton,
            self.filterCollectionView,
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            self.filterAddButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 15),
            self.filterAddButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            self.filterAddButton.widthAnchor.constraint(equalToConstant: 60),
            self.filterAddButton.heightAnchor.constraint(equalToConstant: 40),
            
            self.filterCollectionView.topAnchor.constraint(equalTo: self.filterAddButton.bottomAnchor, constant: 15),
            self.filterCollectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.filterCollectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.filterCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func filterAddButtonTapped(_ button: UIButton) {
        let request = ListFilters.SelectFilter.Request(filterId: nil)
        interactor?.selectFilter(request: request)
        
        self.router?.routeToCreateFilter(segue: nil)
    }
    
    // MARK: Fetched filters
    func fetchFilters() {
        let request = ListFilters.FetchFilters.Request()
        interactor?.fetchFilters(request: request)
    }
    
    func displayFetchedFilters(viewModel: ListFilters.FetchFilters.ViewModel) {
        let filterInfos = viewModel.filterInfos

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(filterInfos, toSection: .main)
        dataSource.apply(snapshot)
    }
}

extension ListFiltersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        let selectedFilterInfo = snapshot.itemIdentifiers[indexPath.row]
        
        let request = ListFilters.SelectFilter.Request(filterId: selectedFilterInfo.filterId)
        self.interactor?.selectFilter(request: request)
        
        self.router?.routeToCreateFilter(segue: nil)
    }
}
