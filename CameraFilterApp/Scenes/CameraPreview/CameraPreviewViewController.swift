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
    
    private var filterCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 120)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private var filterNames:[String] = []
    
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
        
        fetchFilterNames()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let request = CameraPreview.StartSession.Request()
        interactor?.startSession(request)
    }
    
    private func configureUI() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.previewMTKView)
        self.view.addSubview(self.filterCollectionView)

        self.filterCollectionView.delegate = self
        self.filterCollectionView.dataSource = self
        
        self.filterCollectionView.register(FilterCell.self, forCellWithReuseIdentifier: "filterCell")
    }
    
    private func configureAutoLayout() {
        self.previewMTKView.translatesAutoresizingMaskIntoConstraints = false
        self.filterCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.previewMTKView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
            self.previewMTKView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.previewMTKView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.previewMTKView.heightAnchor.constraint(equalTo: self.previewMTKView.widthAnchor, multiplier: 4/3),
            
            self.filterCollectionView.topAnchor.constraint(equalTo: self.previewMTKView.bottomAnchor, constant: 15),
            self.filterCollectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            self.filterCollectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            self.filterCollectionView.heightAnchor.constraint(equalToConstant: 120),
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
    
    // MARK: Do something
    func fetchFilterNames() {
        let request = CameraPreview.FetchFilters.Request()
        interactor?.fetchFilters(request)
    }
    
    func displayFilterNames(viewModel: CameraPreview.FetchFilters.ViewModel) {
        self.filterNames = viewModel.filterNames
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
        
        cell.configure(name: filterNames[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filterNames.count
    }
}

extension CameraPreviewViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filterName = filterNames[indexPath.item]
        let request = CameraPreview.ApplyFilter.Request(filterName: filterName)
        interactor?.applyFilter(request)
    }
}
