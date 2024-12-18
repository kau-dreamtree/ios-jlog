//
//  SettingCell.swift
//  JLog
//
//  Created by 이지수 on 7/7/24.
//
import UIKit

class SettingCell: UICollectionViewCell {
    
    class var identifier: String { return "settingCell" }
    
    private let title: UILabel = {
        let label = UILabel()
        label.font = .smallFont
        label.textColor = .label
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
        
        self.backgroundColor = .secondarySystemGroupedBackground
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }
    
    override func prepareForReuse() {
        self.title.text = ""
    }
    
    func setupLayout() {
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
