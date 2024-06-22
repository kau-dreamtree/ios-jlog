//
//  NarrowLogDetailCell.swift
//  JLog
//
//  Created by 이지수 on 6/22/24.
//

import UIKit

final class NarrowLogDetailCell: UICollectionViewCell {
    
    static let identifier = "narrowLogDetailCell"
    
    struct ViewData {
        let title: String
        let content: String
    }
    
    private let title: UILabel = {
        let label = UILabel()
        label.font = .regularFont
        label.textColor = .secondaryLabel
        return label
    }()
    private let content: UILabel = {
        let label = UILabel()
        label.font = .regularFont
        label.textColor = .label
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 10
    }
    
    override func prepareForReuse() {
        self.title.text = ""
        self.content.text = ""
    }
    
    private func setupLayout() {
        self.addSubviews([self.title, self.content])
        NSLayoutConstraint.activate([
            self.title.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20)
        ])
        NSLayoutConstraint.activate([
            self.content.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.content.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }
    
    func update(with data: ViewData) {
        self.title.text = data.title
        self.content.text = data.content
    }
}
