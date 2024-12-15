//
//  TopLogDetailCell.swift
//  JLog
//
//  Created by 이지수 on 6/22/24.
//

import UIKit

final class TopLogDetailCell: UICollectionViewCell {
    
    static let identifier = "topLogDetailCell"
    
    struct ViewData {
        let name: String
        let amount: String
    }
    
    private let name: UILabel = {
        let label = UILabel()
        label.font = .largeFont
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    private let amount: UILabel = {
        let label = UILabel()
        label.font = .topTitleFont
        label.textColor = .label
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }
    
    override func prepareForReuse() {
        self.name.text = ""
        self.amount.text = ""
    }
    
    private func setupLayout() {
        self.addSubviews([self.name, self.amount])
        NSLayoutConstraint.activate([
            self.name.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            self.name.leadingAnchor.constraint(equalTo: self.amount.leadingAnchor),
            self.name.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -20)
        ])
        NSLayoutConstraint.activate([
            self.amount.topAnchor.constraint(equalTo: self.name.bottomAnchor, constant: 0),
            self.amount.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.amount.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 20),
            self.amount.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -20)
        ])
    }
    
    func update(with data: ViewData) {
        self.name.text = data.name
        self.amount.text = data.amount
    }
}
