//
//  BalanceCell.swift
//  JLog
//
//  Created by 이지수 on 2/17/24.
//

import UIKit

final class BalanceCell: UICollectionViewCell {
    
    static let identifier = "balanceCell"
    
    private let balance: UILabel = {
        let label = UILabel()
        label.font = .topTitleFont
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
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
        self.update(balance: "")
    }
    
    private func setupLayout() {
        self.addSubviews([self.balance])
        NSLayoutConstraint.activate([
            self.balance.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.balance.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.balance.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.balance.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }
    
    func update(balance: String) {
        self.balance.text = balance
    }
}
