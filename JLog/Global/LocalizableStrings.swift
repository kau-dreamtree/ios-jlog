//
//  LocalizableStrings.swift
//  JLog
//
//  Created by 이지수 on 3/1/24.
//

import Foundation

final class LocalizableStrings {
    static func localize(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
