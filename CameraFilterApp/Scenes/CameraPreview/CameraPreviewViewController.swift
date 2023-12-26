//
//  CameraPreviewViewController.swift
//  CameraFilterApp
//
//  Created by siheo on 11/27/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import MetalKit
import PhotosUI

protocol CameraPreviewDisplayLogic: AnyObject
{
    func displayFilterNames(viewModel: CameraPreview.FetchFilters.ViewModel)
    func displayFrameImage(viewModel: CameraPreview.DrawFrameImage.ViewModel)
}

class CameraPreviewViewController: UIViewController, CameraPreviewDisplayLogic
{
    var interactor: CameraPreviewBusinessLogic?
    var router: (NSObjectProtocol & CameraPreviewRoutingLogic & CameraPreviewDataPassing)?
    
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
        let interactor = CameraPreviewInteractor()
        let presenter = CameraPreviewPresenter()
        let router = CameraPreviewRouter()
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
    
    private var previewMTKView: MTKView = MTKView()
    
    private var bottomContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private var galleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 30
        return button
    }()
    
    private var shotButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderColor = UIColor.systemPurple.cgColor
        button.layer.borderWidth = 5
        button.layer.cornerRadius = 40
        return button
    }()
    
    private var filterToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.filters"), for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 30
        return button
    }()
    
    private var filterEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("편집", for: .normal)
        button.tintColor = .systemPurple
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.isHidden = true
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
        collectionView.isHidden = true
        return collectionView
    }()
    
    private var filterInfos:[CameraPreview.FilterInfo] = []
    
    private var ciContext: CIContext?
    private var currentCIImage: CIImage?
    private var currentBuffer: MTLCommandBuffer?
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configureUI()
        configureAutoLayout()
        configureMTKView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let request = CameraPreview.StartSession.Request()
        interactor?.startSession(request)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let request = CameraPreview.PauseSession.Request()
        interactor?.pauseSession(request)
    }
    
    private func configureUI() {
        self.view.backgroundColor = .white
        
        [
            self.previewMTKView,
            self.bottomContentView
        ].forEach { self.view.addSubview($0) }
        
        [
            self.filterToggleButton,
            self.filterEditButton,
            self.filterCollectionView,
            self.galleryButton,
            self.shotButton
        ].forEach { self.bottomContentView.addSubview($0) }
        
        self.filterToggleButton.addTarget(self, action: #selector(filterToggleButtonTapped), for: .touchUpInside)
        self.filterEditButton.addTarget(self, action: #selector(filterEditButtonTapped), for: .touchUpInside)
        self.shotButton.addTarget(self, action: #selector(shotButtonTapped), for: .touchUpInside)
        self.galleryButton.addTarget(self, action: #selector(galleryButtonTapped), for: .touchUpInside)

        self.filterCollectionView.delegate = self
        self.filterCollectionView.dataSource = self
        
        self.filterCollectionView.register(FilterCell.self, forCellWithReuseIdentifier: "filterCell")
    }
    
    private func configureAutoLayout() {
        [
            self.previewMTKView,
            self.bottomContentView,
            self.filterToggleButton,
            self.filterEditButton,
            self.filterCollectionView,
            self.galleryButton,
            self.shotButton,
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            self.previewMTKView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
            self.previewMTKView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.previewMTKView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.previewMTKView.heightAnchor.constraint(equalTo: self.previewMTKView.widthAnchor, multiplier: 4/3),
            
            self.bottomContentView.topAnchor.constraint(equalTo: self.previewMTKView.bottomAnchor),
            self.bottomContentView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.bottomContentView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.bottomContentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.galleryButton.centerYAnchor.constraint(equalTo: self.bottomContentView.centerYAnchor),
            self.galleryButton.widthAnchor.constraint(equalToConstant: 60),
            self.galleryButton.heightAnchor.constraint(equalTo: self.galleryButton.widthAnchor),
            self.galleryButton.leadingAnchor.constraint(equalTo: self.bottomContentView.leadingAnchor, constant: 15),
            
            self.shotButton.centerYAnchor.constraint(equalTo: self.bottomContentView.centerYAnchor),
            self.shotButton.widthAnchor.constraint(equalToConstant: 80),
            self.shotButton.heightAnchor.constraint(equalTo: self.shotButton.widthAnchor),
            self.shotButton.centerXAnchor.constraint(equalTo: self.bottomContentView.centerXAnchor),
            
            self.filterToggleButton.centerYAnchor.constraint(equalTo: self.bottomContentView.centerYAnchor),
            self.filterToggleButton.widthAnchor.constraint(equalToConstant: 60),
            self.filterToggleButton.heightAnchor.constraint(equalTo: self.filterToggleButton.widthAnchor),
            self.filterToggleButton.trailingAnchor.constraint(equalTo: self.bottomContentView.trailingAnchor, constant: -15),
            
            self.filterEditButton.widthAnchor.constraint(equalToConstant: 60),
            self.filterEditButton.heightAnchor.constraint(equalToConstant: 30),
            self.filterEditButton.bottomAnchor.constraint(equalTo: self.filterToggleButton.topAnchor, constant: -10),
            self.filterEditButton.trailingAnchor.constraint(equalTo: self.filterToggleButton.trailingAnchor),
            
            self.filterCollectionView.centerYAnchor.constraint(equalTo: self.bottomContentView.centerYAnchor),
            self.filterCollectionView.leadingAnchor.constraint(equalTo: self.bottomContentView.leadingAnchor, constant: 15),
            self.filterCollectionView.trailingAnchor.constraint(equalTo: self.filterToggleButton.leadingAnchor, constant: -15),
            self.filterCollectionView.heightAnchor.constraint(equalToConstant: 80),
        ])
    }
    
    func configureMTKView() {
        guard let metalDevice = interactor?.metalDevice else { return }
        self.ciContext = CIContext(mtlDevice: metalDevice)
        
        self.previewMTKView.device = metalDevice
        
        self.previewMTKView.isPaused = true
        self.previewMTKView.enableSetNeedsDisplay = false
        
        self.previewMTKView.delegate = self
        
        self.previewMTKView.framebufferOnly = false
    }

    @objc private func filterToggleButtonTapped(_ button: UIButton) {
        if self.filterCollectionView.isHidden {
            fetchFilterNames()
        }
        
        self.filterCollectionView.isHidden.toggle()
        self.filterEditButton.isHidden.toggle()
        self.galleryButton.isHidden.toggle()
        self.shotButton.isHidden.toggle()
    }
    
    @objc private func filterEditButtonTapped(_ button: UIButton) {
        self.filterToggleButtonTapped(self.filterToggleButton)
        
        let selector = NSSelectorFromString("routeToListFiltersWithSegue:")
        if let router = router, router.responds(to: selector) {
            router.perform(selector, with: nil)
        }
    }
    
    @objc private func shotButtonTapped(_ button: UIButton) {
        print(#function)
    }
    
    @objc private func galleryButtonTapped(_ button: UIButton) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        self.present(picker, animated: true)
    }
    
    // MARK: Do something
    func fetchFilterNames() {
        let request = CameraPreview.FetchFilters.Request()
        interactor?.fetchFilters(request)
    }
    
    func displayFilterNames(viewModel: CameraPreview.FetchFilters.ViewModel) {
        self.filterInfos = viewModel.filterInfos
        self.filterCollectionView.reloadData()
    }
    
    func displayFrameImage(viewModel: CameraPreview.DrawFrameImage.ViewModel) {
        self.currentCIImage = viewModel.frameImage
        self.currentBuffer = viewModel.commandBuffer
        
        self.previewMTKView.draw()
    }
}

extension CameraPreviewViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // do nothing
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = self.currentBuffer,
        let ciImage = self.currentCIImage,
        let currentDrawable = view.currentDrawable else { return }
        
        let offset: (x:CGFloat, y:CGFloat) = (
            (view.drawableSize.width - ciImage.extent.width) / 2,
            (view.drawableSize.height - ciImage.extent.height) / 2
        )

        self.ciContext?.render(ciImage,
                              to: currentDrawable.texture,
                              commandBuffer: commandBuffer,
                              bounds: CGRect(origin: CGPoint(x: -offset.x, y: -offset.y), size: view.drawableSize),
                              colorSpace: CGColorSpaceCreateDeviceRGB())
        
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
}

extension CameraPreviewViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as? FilterCell else { return UICollectionViewCell() }
        
        let filterInfo = filterInfos[indexPath.row]
        
        cell.configure(name: filterInfo.filterName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filterInfos.count
    }
}

extension CameraPreviewViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filterId = filterInfos[indexPath.item].filterId
        let request = CameraPreview.ApplyFilter.Request(filterId: filterId)
        interactor?.applyFilter(request)
    }
}

extension CameraPreviewViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider, 
            itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self,
                    let image = image as? UIImage else { return }
                
                DispatchQueue.main.async {
                    let request = CameraPreview.SelectPhoto.Request(photo: image)
                    self.interactor?.selectPhoto(request)
                    
                    let selector = NSSelectorFromString("routeToEditPhotoWithSegue:")
                    if let router = self.router, router.responds(to: selector) {
                        router.perform(selector, with: nil)
                    }
                }
            }
        } else {
            print("cannot load image")
        }
    }
}
