//
//  CreateFilterViewController.swift
//  CameraFilterApp
//
//  Created by ShinIl Heo on 12/2/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol CreateFilterDisplayLogic: AnyObject
{
    func displayFetchedFilter(viewModel: CreateFilter.FetchFilter.ViewModel)
    func displayFetchedCategories(viewModel: CreateFilter.FetchFilterCategories.ViewModel)
    func displayFetchedProperties(viewModel: CreateFilter.FetchProperties.ViewModel)
    func displayFilterAppliedSampleImage(viewModel: CreateFilter.ApplyFilter.ViewModel)
    func displayCreatedFilter(viewModel: CreateFilter.CreateFilter.ViewModel)
    func displayEditedFilter(viewModel: CreateFilter.EditFilter.ViewModel)
    func displayDeletedFilter(viewModel: CreateFilter.DeleteFilter.ViewModel)
}

class CreateFilterViewController: UIViewController, CreateFilterDisplayLogic
{
    var interactor: CreateFilterBusinessLogic?
    var router: (NSObjectProtocol & CreateFilterRoutingLogic & CreateFilterDataPassing)?
    
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
        let interactor = CreateFilterInteractor()
        let presenter = CreateFilterPresenter()
        let router = CreateFilterRouter()
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
    
    // MARK: - private properties
    private var categoryNames:[String] = []
    
    // MARK: - UI components
    private var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("닫기", for: .normal)
        button.tintColor = .systemPurple
        button.titleLabel?.font = .systemFont(ofSize: 18)
        return button
    }()
    
    private var exampleTextLabel: UILabel = {
        let label = UILabel()
        label.text = "필터 예시"
        label.font = .systemFont(ofSize: 18)
        label.tintColor = .black
        label.textAlignment = .left
        return label
    }()
    
    private var sampleImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private var filterDisplayNameLabel: UILabel = {
        let label = UILabel()
        label.text = "필터명"
        label.font = .systemFont(ofSize: 18)
        label.tintColor = .black
        label.textAlignment = .left
        return label
    }()
    
    private var filterDisplayNameTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = .black
        tf.textAlignment = .left
        tf.backgroundColor = .systemGray6
        tf.font = .systemFont(ofSize: 18)
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    private var filterCategoryLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리"
        label.font = .systemFont(ofSize: 18)
        label.tintColor = .black
        label.textAlignment = .left
        return label
    }()
    
    private var filterCategoryPickerView = UIPickerView()
    
    private var filterCategoryTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = .black
        tf.textAlignment = .left
        tf.backgroundColor = .systemGray6
        tf.font = .systemFont(ofSize: 18)
        tf.tintColor = .clear
        return tf
    }()
    
    private var propertyScrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        return view
    }()
    
    private var propertyStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 15
        return view
    }()
    
    private var inputColorPickerView = {
        let view = ColorPickerPropertyView()
        view.contentView.isHidden = true
        return view
    }()
    
    private var inputIntensitySliderView = {
        let view = SliderPropertyView()
        view.contentView.isHidden = true
        return view
    }()
    
    private var inputRadiusSliderView = {
        let view = SliderPropertyView()
        view.contentView.isHidden = true
        return view
    }()
    
    private var inputLevelsSliderView = {
        let view = SliderPropertyView()
        view.contentView.isHidden = true
        return view
    }()
    
    private var buttonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.distribution = .fillEqually
        return view
    }()
    
    private var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setTitle("생성", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .systemPurple
        button.layer.cornerRadius = 10
        button.isHidden = true
        return button
    }()
    
    private var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setTitle("삭제", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 10
        button.isHidden = true
        return button
    }()
    
    private var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setTitle("수정", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.isHidden = true
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
        configureAutoLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchFilter()
        fetchFilterCategories()
    }

    private func configureUI() {
        self.view.backgroundColor = .white
        
        self.filterCategoryPickerView.delegate = self
        self.filterCategoryPickerView.dataSource = self

        let toolbar: UIToolbar = configureToolbar()
        self.filterCategoryTextField.inputAccessoryView = toolbar
        self.filterCategoryTextField.inputView = self.filterCategoryPickerView
        
        self.filterDisplayNameTextField.delegate = self
        
        self.inputColorPickerView.delegate = self
        self.inputIntensitySliderView.delegate = self
        self.inputRadiusSliderView.delegate = self
        self.inputLevelsSliderView.delegate = self
        
        self.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        self.createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        self.editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        self.deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        [
            self.closeButton,
            self.exampleTextLabel,
            self.sampleImageView,
            self.filterDisplayNameLabel,
            self.filterDisplayNameTextField,
            self.filterCategoryLabel,
            self.filterCategoryTextField,
            self.propertyScrollView,
            self.propertyStackView,
            self.buttonStackView,
            self.indicatorView,
        ].forEach { self.view.addSubview($0) }
        
        [
            self.propertyStackView
        ].forEach { self.propertyScrollView.addSubview($0) }
        
        [
            self.createButton,
            self.deleteButton,
            self.editButton,
        ].forEach { self.buttonStackView.addArrangedSubview($0) }
        
        [
            self.inputColorPickerView as PropertyView,
            self.inputIntensitySliderView,
            self.inputRadiusSliderView,
            self.inputLevelsSliderView,
        ].forEach { self.propertyStackView.addArrangedSubview($0.contentView) }
    }
    
    private func configureToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(systemItem: .flexibleSpace)
        
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(filterCategoryTextFieldDoneButtonTapped))
        
        toolbar.items = [flexibleSpace, doneButton]
        
        return toolbar
    }
    
    private func configureAutoLayout() {
        [
            self.closeButton,
            self.exampleTextLabel,
            self.sampleImageView,
            self.filterDisplayNameLabel,
            self.filterDisplayNameTextField,
            self.filterCategoryLabel,
            self.filterCategoryTextField,
            self.propertyScrollView,
            self.buttonStackView,

            self.propertyStackView,

            self.createButton,
            self.deleteButton,
            self.editButton,
            
            self.indicatorView,
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        // self.view's subviews
        NSLayoutConstraint.activate([
            self.closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 15),
            self.closeButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            self.closeButton.widthAnchor.constraint(equalToConstant: 60),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            self.sampleImageView.topAnchor.constraint(equalTo: self.closeButton.bottomAnchor, constant: 15),
            self.sampleImageView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.sampleImageView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.33),
            self.sampleImageView.heightAnchor.constraint(equalTo: self.sampleImageView.widthAnchor, multiplier: 1.0),

            self.exampleTextLabel.topAnchor.constraint(equalTo: self.sampleImageView.bottomAnchor, constant: 5),
            self.exampleTextLabel.centerXAnchor.constraint(equalTo: self.sampleImageView.centerXAnchor),
            self.exampleTextLabel.heightAnchor.constraint(equalToConstant: 30),
            
            self.filterCategoryLabel.topAnchor.constraint(equalTo: self.exampleTextLabel.bottomAnchor, constant: 15),
            self.filterCategoryLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            self.filterCategoryLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            self.filterCategoryLabel.heightAnchor.constraint(equalToConstant: 30),
            
            self.filterCategoryTextField.topAnchor.constraint(equalTo: self.filterCategoryLabel.bottomAnchor, constant: 5),
            self.filterCategoryTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            self.filterCategoryTextField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            self.filterCategoryTextField.heightAnchor.constraint(equalToConstant: 45),
            
            self.filterDisplayNameLabel.topAnchor.constraint(equalTo: self.filterCategoryTextField.bottomAnchor, constant: 15),
            self.filterDisplayNameLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            self.filterDisplayNameLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            self.filterDisplayNameLabel.heightAnchor.constraint(equalToConstant: 30),
            
            self.filterDisplayNameTextField.topAnchor.constraint(equalTo: self.filterDisplayNameLabel.bottomAnchor, constant: 5),
            self.filterDisplayNameTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            self.filterDisplayNameTextField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            self.filterDisplayNameTextField.heightAnchor.constraint(equalToConstant: 45),
            
            self.propertyScrollView.topAnchor.constraint(equalTo: self.filterDisplayNameTextField.bottomAnchor, constant: 15),
            self.propertyScrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            self.propertyScrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            self.propertyScrollView.bottomAnchor.constraint(equalTo: self.buttonStackView.topAnchor, constant: -15),
            
            self.buttonStackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            self.buttonStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            self.buttonStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            self.buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            
            self.indicatorView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.indicatorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.indicatorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.indicatorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        
        // buttonStackView's subviews
        NSLayoutConstraint.activate([
            self.createButton.heightAnchor.constraint(equalToConstant: 60),
            
            self.editButton.heightAnchor.constraint(equalToConstant: 60),
            
            self.deleteButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        // propertyScrollView's subviews
        NSLayoutConstraint.activate([
            self.propertyStackView.topAnchor.constraint(equalTo: self.propertyScrollView.topAnchor),
            self.propertyStackView.leadingAnchor.constraint(equalTo: self.propertyScrollView.leadingAnchor),
            self.propertyStackView.trailingAnchor.constraint(equalTo: self.propertyScrollView.trailingAnchor),
            self.propertyStackView.bottomAnchor.constraint(equalTo: self.propertyScrollView.bottomAnchor),
            
            self.propertyStackView.widthAnchor.constraint(equalTo: self.propertyScrollView.widthAnchor)
        ])
        
        // propertyStackView's subviews
        NSLayoutConstraint.activate([
            self.inputColorPickerView.contentView.heightAnchor.constraint(equalToConstant: 70),
            self.inputColorPickerView.contentView.widthAnchor.constraint(equalTo: self.propertyStackView.widthAnchor),
            
            self.inputIntensitySliderView.contentView.heightAnchor.constraint(equalToConstant: 95),
            self.inputIntensitySliderView.contentView.widthAnchor.constraint(equalTo: self.propertyStackView.widthAnchor),
            
            self.inputRadiusSliderView.contentView.heightAnchor.constraint(equalToConstant: 95),
            self.inputRadiusSliderView.contentView.widthAnchor.constraint(equalTo: self.propertyStackView.widthAnchor),
            
            self.inputLevelsSliderView.contentView.heightAnchor.constraint(equalToConstant: 95),
            self.inputLevelsSliderView.contentView.widthAnchor.constraint(equalTo: self.propertyStackView.widthAnchor),
        ])
    }
    
    // MARK: - CreateFilterBusinessLogic
    private func showIndicatorView() {
        self.indicatorView.isHidden = false
        if self.indicatorView.isAnimating == false {
            self.indicatorView.startAnimating()
        }
    }
    
    func fetchFilter() {
        showIndicatorView()
        
        let request = CreateFilter.FetchFilter.Request()
        interactor?.fetchFilter(request: request)
    }
    
    func fetchFilterCategories() {
        showIndicatorView()
        
        let request = CreateFilter.FetchFilterCategories.Request()
        interactor?.fetchFilterCategories(request: request)
    }
    
    // MARK: - CreateFilterDisplayLogic
    private func hideIndicatorView() {
        self.indicatorView.isHidden = true
        if self.indicatorView.isAnimating == true {
            self.indicatorView.stopAnimating()
        }
    }
    
    func displayFetchedFilter(viewModel: CreateFilter.FetchFilter.ViewModel) {
        self.sampleImageView.image = viewModel.sampleImage
        
        if let filterInfo = viewModel.filterInfo {
            self.editButton.isHidden = false
            self.deleteButton.isHidden = false
            
            let filterName = filterInfo.filterName
            let filterSystemName = filterInfo.filterSystemName
            
            self.filterDisplayNameTextField.text = filterName
            self.filterCategoryTextField.text = filterSystemName?.rawValue
            
            if let inputColor = filterInfo.inputColor {
                self.inputColorPickerView.contentView.isHidden = false
                
                self.inputColorPickerView.configure(selectedColor: inputColor)
            }
            
            if let inputIntensity = filterInfo.inputIntensity {
                self.inputIntensitySliderView.contentView.isHidden = false
                
                self.inputIntensitySliderView.configure(propertyName: "강도", propertyMinValue: Float(inputIntensity.min), propertyMaxValue: Float(inputIntensity.max), propertyCurrentValue: Float(inputIntensity.value))
            }
            
            if let inputRadius = filterInfo.inputRadius {
                self.inputRadiusSliderView.contentView.isHidden = false
                
                self.inputRadiusSliderView.configure(propertyName: "범위", propertyMinValue: Float(inputRadius.min), propertyMaxValue: Float(inputRadius.max), propertyCurrentValue: Float(inputRadius.value))
            }
            
            if let inputLevels = filterInfo.inputLevels {
                self.inputLevelsSliderView.contentView.isHidden = false
                
                self.inputLevelsSliderView.configure(propertyName: "레벨", propertyMinValue: Float(inputLevels.min), propertyMaxValue: Float(inputLevels.max), propertyCurrentValue: Float(inputLevels.value))
            }
        } else {
            self.createButton.isHidden = false
        }
        
        hideIndicatorView()
    }

    func displayFetchedCategories(viewModel: CreateFilter.FetchFilterCategories.ViewModel) {
        let categoryNames = viewModel.filterCategories
        self.categoryNames = categoryNames
        
        hideIndicatorView()
    }

    func displayFetchedProperties(viewModel: CreateFilter.FetchProperties.ViewModel) {
        [
            self.inputColorPickerView as PropertyView,
            self.inputIntensitySliderView,
            self.inputRadiusSliderView,
            self.inputLevelsSliderView
        ].forEach { $0.contentView.isHidden = true }
        
        if let inputColor = viewModel.inputColor {
            self.inputColorPickerView.contentView.isHidden = false
            
            self.inputColorPickerView.configure(selectedColor: inputColor)
        }
        
        if let inputIntensity = viewModel.inputIntensity {
            self.inputIntensitySliderView.contentView.isHidden = false
            
            self.inputIntensitySliderView.configure(propertyName: "강도", propertyMinValue: Float(inputIntensity.min), propertyMaxValue: Float(inputIntensity.max), propertyCurrentValue: Float(inputIntensity.value))
        }
        
        if let inputRadius = viewModel.inputRadius {
            self.inputRadiusSliderView.contentView.isHidden = false
            
            self.inputRadiusSliderView.configure(propertyName: "범위", propertyMinValue: Float(inputRadius.min), propertyMaxValue: Float(inputRadius.max), propertyCurrentValue: Float(inputRadius.value))
        }
        
        if let inputLevels = viewModel.inputLevels {
            self.inputLevelsSliderView.contentView.isHidden = false
            
            self.inputLevelsSliderView.configure(propertyName: "레벨", propertyMinValue: Float(inputLevels.min), propertyMaxValue: Float(inputLevels.max), propertyCurrentValue: Float(inputLevels.value))
        }
        
        hideIndicatorView()
    }
    
    func displayFilterAppliedSampleImage(viewModel: CreateFilter.ApplyFilter.ViewModel) {
        let sampleImage: UIImage? = viewModel.filteredImage
        
        self.sampleImageView.image = sampleImage
    }

    func displayCreatedFilter(viewModel: CreateFilter.CreateFilter.ViewModel) {
        if let _ = viewModel.filterInfo {
            routeToListFilters()
        } else {
            let alertController = UIAlertController(title: "에러", message: "필터를 생성할 수 없습니다", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "확인", style: .default)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true)
        }
        
        hideIndicatorView()
    }

    func displayEditedFilter(viewModel: CreateFilter.EditFilter.ViewModel) {
        if let _ = viewModel.filterInfo {
            self.router?.routeToListFilters(segue: nil)
        } else {
            let alertController = UIAlertController(title: "에러", message: "필터를 수정할 수 없습니다", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "확인", style: .default)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true)
        }
        
        hideIndicatorView()
    }

    func displayDeletedFilter(viewModel: CreateFilter.DeleteFilter.ViewModel) {
        if let _ = viewModel.filterInfo {
            routeToListFilters()
        } else {
            let alertController = UIAlertController(title: "에러", message: "필터를 삭제할 수 없습니다", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "확인", style: .default)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true)
        }
        
        hideIndicatorView()
    }
    
    // MARK: - Private methods
    private func routeToListFilters() {
        self.router?.routeToListFilters(segue: nil)
    }
    
    @objc private func closeButtonTapped(_ button: UIButton) {
        routeToListFilters()
    }
    
    @objc private func createButtonTapped(_ button: UIButton) {
        guard let displayName = self.filterDisplayNameTextField.text,
        let filterSystemName = CameraFilter.FilterName(rawValue: self.filterCategoryTextField.text ?? "") else {
            return
        }
        
        showIndicatorView()
        
        let request = CreateFilter.CreateFilter.Request(
            filterName: displayName,
            filterSystemName: filterSystemName,
            inputColor: self.inputColorPickerView.selectedColor,
            inputIntensity: CGFloat(self.inputIntensitySliderView.sliderValue),
            inputRadius: CGFloat(self.inputRadiusSliderView.sliderValue),
            inputLevels: CGFloat(self.inputLevelsSliderView.sliderValue))
        
        interactor?.createFilter(request: request)
    }
    
    @objc private func editButtonTapped(_ button: UIButton) {
        guard let displayName = self.filterDisplayNameTextField.text,
        let filterSystemName = CameraFilter.FilterName(rawValue: self.filterCategoryTextField.text ?? "") else {
            return
        }
        
        showIndicatorView()
        
        let request = CreateFilter.EditFilter.Request(
            filterName: displayName,
            filterSystemName: filterSystemName,
            inputColor: self.inputColorPickerView.selectedColor,
            inputIntensity: CGFloat(self.inputIntensitySliderView.sliderValue),
            inputRadius: CGFloat(self.inputRadiusSliderView.sliderValue),
            inputLevels: CGFloat(self.inputLevelsSliderView.sliderValue))
        
        interactor?.editFilter(request: request)
    }
    
    @objc private func deleteButtonTapped(_ button: UIButton) {
        showIndicatorView()
        
        let request = CreateFilter.DeleteFilter.Request()
        interactor?.deleteFilter(request: request)
    }
    
    @objc private func filterCategoryTextFieldDoneButtonTapped(_ button: UIBarButtonItem) {
        self.filterCategoryTextField.resignFirstResponder()
    }
    
    private func fetchFilterAppliedImage() {
        if let filterSystemName = CameraFilter.FilterName(rawValue: self.filterCategoryTextField.text ?? "") {
            let request = CreateFilter.ApplyFilter.Request(
                filterSystemName: filterSystemName,
                inputColor: self.inputColorPickerView.selectedColor,
                inputIntensity: CGFloat(self.inputIntensitySliderView.sliderValue),
                inputRadius: CGFloat(self.inputRadiusSliderView.sliderValue),
                inputLevels: CGFloat(self.inputLevelsSliderView.sliderValue))
            
            interactor?.applyFilter(request: request)
        }
    }
}

// MARK: - UIPickerViewDelegate
extension CreateFilterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryNames[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard !self.categoryNames.isEmpty else { return }
        
        let selectedCategory = self.categoryNames[row]
        self.filterCategoryTextField.text = selectedCategory
        
        if let filterSystemName = CameraFilter.FilterName(rawValue: selectedCategory) {
            let request = CreateFilter.FetchProperties.Request(filterSystemName: filterSystemName)
            self.interactor?.fetchProperties(request: request)
            
            fetchFilterAppliedImage()
        }
    }
}

//MARK: - UITextFieldDelegate
extension CreateFilterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - SliderPropertyViewDelegate, ColorPickerPropertyViewDelegate
extension CreateFilterViewController: SliderPropertyViewDelegate, ColorPickerPropertyViewDelegate {
    func sliderValueChanged(_ propertyView: SliderPropertyView, newValue: Float) {
        fetchFilterAppliedImage()
    }
    
    func colorValueChanged(_ propertyView: ColorPickerPropertyView, newColor: UIColor?) {
        fetchFilterAppliedImage()
    }
}
