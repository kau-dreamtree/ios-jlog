//
//  SettingCell.swift
//  JLog
//
//  Created by 이지수 on 7/7/24.
//
import UIKit

final class SettingCell: UICollectionViewCell {
    
    static let identifier = "settingCell"
    
    private let title: UILabel = {
        let label = UILabel()
        label.font = .regularFont
        label.textColor = .label
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
        self.title.text = ""
    }
    
    private func setupLayout() {
        self.addSubviews([self.title])
        NSLayoutConstraint.activate([
            self.title.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.title.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }
    
    func update(title: String) {
        self.title.text = title
    }
}
