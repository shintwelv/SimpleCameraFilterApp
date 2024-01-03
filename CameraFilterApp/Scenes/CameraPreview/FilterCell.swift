//
//  FilterCell.swift
//  CameraFilterApp
//
//  Created by ShinIl Heo on 11/28/23.
//

import UIKit

class FilterCell: UICollectionViewCell {
    
    private var sampleImageView: UIImageView!
    private var nameLabel: UILabel!

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
        self.sampleImageView = {
            let view = UIImageView()
            view.contentMode = .scaleAspectFit
            return view
        }()
        
        self.nameLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 12)
            label.textColor = .black
            label.textAlignment = .center
            label.numberOfLines = 1
            label.lineBreakMode = .byTruncatingTail
            return label
        }()
        
        [
            self.nameLabel,
            self.sampleImageView,
        ].forEach { self.contentView.addSubview($0) }
    }
    
    private func configureAutoLayout() {
        [
            self.nameLabel,
            self.sampleImageView,
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            self.sampleImageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.sampleImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.sampleImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20),
            self.sampleImageView.widthAnchor.constraint(equalTo: self.sampleImageView.heightAnchor),
            
            self.nameLabel.widthAnchor.constraint(equalTo: self.sampleImageView.widthAnchor),
            self.nameLabel.topAnchor.constraint(equalTo: self.sampleImageView.bottomAnchor, constant: 5),
            self.nameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.nameLabel.centerXAnchor.constraint(equalTo: self.sampleImageView.centerXAnchor),
        ])
    }
    
    func configure(name: String, filterAppliedImage: UIImage) {
        self.nameLabel.text = name
        self.sampleImageView.image = filterAppliedImage
    }
}
