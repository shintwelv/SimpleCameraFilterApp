//
//  SliderPropertyView.swift
//  CameraFilterApp
//
//  Created by siheo on 12/5/23.
//

import UIKit

class SliderPropertyView: PropertyView {
    
    let contentView = UIView()
    
    // MARK: - Subviews
    private var propertyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.tintColor = .black
        label.textAlignment = .left
        label.text = "속성"
        return label
    }()
    
    private var propertyMinLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.tintColor = .black
        label.textAlignment = .center
        label.text = "0"
        return label
    }()
    
    private var propertyMaxLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.tintColor = .black
        label.textAlignment = .center
        label.text = "1"
        return label
    }()
    
    private var propertyValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.tintColor = .black
        label.textAlignment = .center
        label.text = "0.5"
        return label
    }()
    
    private var propertySlider: UISlider = {
        let slider = UISlider()
        slider.isContinuous = false
        return slider
    }()
    
    // MARK: - Initializer
    init() {
        configureUI()
        configureAutoLayout()
    }
    
    // MARK: - UI
    private func configureUI() {
        [
            self.propertyLabel,
            self.propertyMinLabel,
            self.propertyMaxLabel,
            self.propertyValueLabel,
            self.propertySlider,
        ].forEach { self.contentView.addSubview($0) }
    }
    
    private func configureAutoLayout() {
        [
            self.contentView,
            self.propertyLabel,
            self.propertyMinLabel,
            self.propertyMaxLabel,
            self.propertyValueLabel,
            self.propertySlider,
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            self.propertyLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.propertyLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.propertyLabel.heightAnchor.constraint(equalToConstant: 30),
            self.propertyLabel.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
            
            self.propertySlider.topAnchor.constraint(equalTo: self.propertyLabel.bottomAnchor, constant: 5),
            self.propertySlider.leadingAnchor.constraint(equalTo: self.propertyMinLabel.trailingAnchor, constant: 5),
            self.propertySlider.trailingAnchor.constraint(equalTo: self.propertyMaxLabel.leadingAnchor, constant: -5),
            self.propertySlider.heightAnchor.constraint(equalToConstant: 50),
            
            self.propertyMinLabel.centerYAnchor.constraint(equalTo: self.propertySlider.centerYAnchor),
            self.propertyMinLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.propertyMinLabel.widthAnchor.constraint(equalToConstant: 30),
            self.propertyMinLabel.heightAnchor.constraint(equalToConstant: 50),
            
            self.propertyMaxLabel.centerYAnchor.constraint(equalTo: self.propertySlider.centerYAnchor),
            self.propertyMaxLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.propertyMaxLabel.widthAnchor.constraint(equalToConstant: 30),
            self.propertyMaxLabel.heightAnchor.constraint(equalToConstant: 50),
            
            self.propertyValueLabel.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
            self.propertyValueLabel.topAnchor.constraint(equalTo: self.propertySlider.bottomAnchor),
            self.propertyValueLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.propertyValueLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    // MARK: - Configure value
    func configure(propertyName:String, propertyMinValue: Float, propertyMaxValue: Float, propertyCurrentValue: Float) {
        self.propertyLabel.text = propertyName
        self.propertySlider.minimumValue = propertyMinValue
        self.propertySlider.minimumValue = propertyMaxValue
        self.propertySlider.setValue(propertyCurrentValue, animated: false)
    }
}
