//
//  LogCell.swift
//  JLog
//
//  Created by 이지수 on 2/17/24.
//

import UIKit

final class LogCell: UICollectionViewCell {
    
    static let identifier = "logCell"
    
    struct ViewData {
        let log: LogDTO
        let isMine: Bool
    }
    
    private let date: UILabel = {
        let label = UILabel()
        label.font = .smallFont
        label.textColor = .tertiaryLabel
        return label
    }()
    private let name: UILabel = {
        let label = UILabel()
        label.font = .regularFont
        label.textColor = .label
        return label
    }()
    private let memo: UIImageView = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 14)
        let image = UIImage(systemName: "text.bubble", withConfiguration: imageConfig)
        let view = UIImageView(image: image)
        view.tintColor = .tertiaryLabel
        return view
    }()
    private let amount: UILabel = {
        let label = UILabel()
        label.font = .regularFont
        label.textColor = .label
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
        self.addSubviews([self.name, self.date, self.memo, self.amount])
        NSLayoutConstraint.activate([
            self.name.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.name.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20)
        ])
        NSLayoutConstraint.activate([
            self.date.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.date.leadingAnchor.constraint(equalTo: self.name.trailingAnchor, constant: 10)
        ])
        NSLayoutConstraint.activate([
            self.memo.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.memo.leadingAnchor.constraint(equalTo: self.date.trailingAnchor, constant: 10)
        ])
        NSLayoutConstraint.activate([
            self.amount.leadingAnchor.constraint(greaterThanOrEqualTo: self.memo.trailingAnchor, constant: 10),
            self.amount.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.amount.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }
    
    func update(with data: ViewData) {
        self.date.text = data.log.stringCreatedAt
        self.name.text = data.log.username
        self.memo.isHidden = data.log.memo.isEmptyOrNil
        self.amount.text = data.log.amount.currency
        self.backgroundColor = data.isMine ? .secondarySystemFill : .systemBackground
    }
}
