//
//  WideLogDetailCell.swift
//  JLog
//
//  Created by 이지수 on 6/22/24.
//

import UIKit

final class WideLogDetailCell: UICollectionViewCell {
    
    static let identifier = "wideLogDetailCell"
    
    struct ViewData {
        let title: String
        let content: String
    }
    
    private let title: UILabel = {
        let label = UILabel()
        label.font = .regularFont
        label.textColor = .label
        return label
    }()
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    private let content: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.font = .smallFont
        view.textColor = .label
        view.textContainer.lineFragmentPadding = 0
        view.backgroundColor = .clear
        return view
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
        self.addSubviews([self.title, self.divider, self.content])
        NSLayoutConstraint.activate([
            self.title.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            self.title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20)
        ])
        NSLayoutConstraint.activate([
            self.divider.topAnchor.constraint(equalTo: self.title.bottomAnchor, constant: 5),
            self.divider.heightAnchor.constraint(equalToConstant: 1),
            self.divider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            self.divider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ])
        NSLayoutConstraint.activate([
            self.content.topAnchor.constraint(equalTo: self.title.bottomAnchor, constant: 10),
            self.content.leadingAnchor.constraint(equalTo: self.title.leadingAnchor),
            self.content.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.content.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 10)
        ])
    }
    
    func update(with data: ViewData) {
        self.title.text = data.title
        self.content.text = data.content
    }
}
