//
//  ColorPickerPropertyView.swift
//  CameraFilterApp
//
//  Created by siheo on 12/5/23.
//

import UIKit

protocol ColorPickerPropertyViewDelegate {
    func colorValueChanged(_ propertyView: ColorPickerPropertyView, newColor:UIColor?)
}

class ColorPickerPropertyView: PropertyView {
    
    let contentView = UIView()
    
    var delegate: ColorPickerPropertyViewDelegate?
    
    var selectedColor: UIColor? {
        self.selectedColorView.backgroundColor
    }
    
    // MARK: - Subviews
    private var inputColorLabel: UILabel = {
        let label = UILabel()
        label.text = "색상"
        label.font = .systemFont(ofSize: 18)
        label.tintColor = .black
        label.textAlignment = .left
        return label
    }()
    
    private var selectedColorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private var colorControl: UIColorWell = {
        let well = UIColorWell()
        well.supportsAlpha = false
        return well
    }()
    
    // MARK: - Initializer
    init() {
        configureUI()
        configureAutoLayout()
    }
    
    // MARK: - UI
    private func configureUI() {
        
        self.colorControl.addTarget(self, action: #selector(colorChanged), for: .valueChanged)
        
        [
            self.inputColorLabel,
            self.selectedColorView,
            self.colorControl,
        ].forEach { self.contentView.addSubview($0) }
    }
    
    private func configureAutoLayout() {
        [
            self.inputColorLabel,
            self.selectedColorView,
            self.colorControl,
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            self.inputColorLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.inputColorLabel.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.5),
            self.inputColorLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.inputColorLabel.heightAnchor.constraint(equalToConstant: 50),
            
            self.selectedColorView.trailingAnchor.constraint(equalTo: self.colorControl.leadingAnchor, constant: -10),
            self.selectedColorView.widthAnchor.constraint(equalTo: self.inputColorLabel.heightAnchor),
            self.selectedColorView.heightAnchor.constraint(equalToConstant: 30),
            self.selectedColorView.centerYAnchor.constraint(equalTo: self.colorControl.centerYAnchor),
            
            self.colorControl.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.colorControl.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.colorControl.widthAnchor.constraint(equalTo: self.inputColorLabel.heightAnchor),
            self.colorControl.heightAnchor.constraint(equalTo: self.inputColorLabel.heightAnchor),
        ])
    }
    
    // MARK: - Configure value
    func configure(selectedColor: UIColor) {
        self.selectedColorView.backgroundColor = selectedColor
    }
    
    //MARK: - Private methods
    @objc private func colorChanged(_ colorPicker: UIColorWell) {
        self.selectedColorView.backgroundColor = colorPicker.selectedColor
        
        self.delegate?.colorValueChanged(self, newColor: colorPicker.selectedColor)
    }
}
