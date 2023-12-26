//
//  FilterCell.swift
//  CameraFilterApp
//
//  Created by ShinIl Heo on 11/28/23.
//

import UIKit

class FilterCell: UICollectionViewCell {
    
    var nameLabel: UILabel!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureCell()
        configureAutoLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
        configureAutoLayout()
    }
    
    private func configureCell() {
        self.nameLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 18)
            label.textColor = .black
            label.textAlignment = .center
            label.numberOfLines = 1
            label.lineBreakMode = .byTruncatingTail
            return label
        }()
        
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.black.cgColor
        
        self.contentView.addSubview(nameLabel)
    }
    
    private func configureAutoLayout() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 1.0),
            nameLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
    }
    
    func configure(name: String) {
        self.nameLabel.text = name
    }
}
