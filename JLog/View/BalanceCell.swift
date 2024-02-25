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
        label.font = .balanceFont
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
        self.update(balance: "")
    }
    
    private func setupLayout() {
        self.addSubviews([self.balance])
        NSLayoutConstraint.activate([
            self.balance.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.balance.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    func update(balance: String) {
        self.balance.text = balance
    }
}

private extension UIFont {
    static let balanceFont = UIFont.systemFont(ofSize: 40, weight: .semibold)
}
