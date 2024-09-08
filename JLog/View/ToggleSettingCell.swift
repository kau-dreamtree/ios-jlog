//
//  ToggleSettingCell.swift
//  JLog
//
//  Created by 이지수 on 9/8/24.
//

import UIKit

final class ToggleSettingCell: SettingCell {
    override class var identifier: String { return "toggleSettingCell" }
    
    private let toggle: UISwitch = {
        return UISwitch()
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.toggle.isOn = false
    }
    
    override func setupLayout() {
        super.setupLayout()
        self.addSubviews([self.toggle])
        NSLayoutConstraint.activate([
            self.toggle.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.toggle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }
    
    func update(title: String, isOn: Bool, action: @escaping (Bool) -> Void) {
        super.update(title: title)
        toggle.isOn = isOn
        toggle.addAction(.init(handler: { [weak toggle] _ in
            guard let toggle else { return }
            action(toggle.isOn)
        }), for: .valueChanged)
    }
}
