//
//  UIFont+Extension.swift
//  JLog
//
//  Created by 이지수 on 2/16/24.
//

import UIKit

extension UIFont {
    static let topTitleFont = UIFont.systemFont(ofSize: 40, weight: .semibold)
    static let titleFont = UIFont.systemFont(ofSize: 25, weight: .bold)
    static let largeFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
    static let regularFont = UIFont.systemFont(ofSize: 17, weight: .medium)
    static let smallFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    
    static let logo = UIFont(name: "Avenir Book", size: 25)
}


extension UIColor {
    static let buttonTitle = UIColor.systemBackground
    static let buttonOn = UIColor.label
    static let buttonOff = UIColor.quaternaryLabel
}
