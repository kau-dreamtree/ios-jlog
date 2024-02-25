//
//  Collection+Extension.swift
//  JLog
//
//  Created by 이지수 on 2/17/24.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
