//
//  ListFilterCell.swift
//  CameraFilterApp
//
//  Created by ShinIl Heo on 12/2/23.
//

import UIKit

class ListFilterCell: UICollectionViewCell {
    
    var filterAppliedImageView: UIImageView!
    var filterNameLabel: UILabel!
    
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
        self.filterAppliedImageView = {
            let view = UIImageView()
            view.contentMode = .scaleAspectFill
            return view
        }()
        
        self.filterNameLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 18)
            label.textColor = .black
            label.textAlignment = .center
            label.numberOfLines = 1
            label.adjustsFontSizeToFitWidth = true
            return label
        }()
        
        [
            self.filterAppliedImageView,
            self.filterNameLabel
        ].forEach { self.contentView.addSubview($0) }
    }
    
    private func configureAutoLayout() {
        [
            self.filterAppliedImageView,
            self.filterNameLabel
        ].forEach { $0?.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            self.filterAppliedImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.filterAppliedImageView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
            self.filterAppliedImageView.heightAnchor.constraint(equalTo: self.filterAppliedImageView.widthAnchor),
            self.filterAppliedImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            
            self.filterNameLabel.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
            self.filterNameLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.filterNameLabel.topAnchor.constraint(equalTo: self.filterAppliedImageView.bottomAnchor, constant: 10),
            self.filterNameLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(filterInfo: ListFilters.FilterInfo) {
        self.filterAppliedImageView.image = filterInfo.filterAppliedImage
        self.filterNameLabel.text = filterInfo.filterName
    }
}
