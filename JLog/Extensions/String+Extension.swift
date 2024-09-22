//
//  String+Extension.swift
//  JLog
//
//  Created by 이지수 on 6/21/24.
//

import Foundation

extension String? {
    var isEmptyOrNil: Bool {
        guard let self else { return true }
        return self.isEmpty
    }
}
