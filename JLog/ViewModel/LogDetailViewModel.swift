//
//  LogDetailViewModel.swift
//  JLog
//
//  Created by 이지수 on 6/22/24.
//

import Foundation

struct LogDetailViewModel: LogDetailViewModelProtocol {
    
    private let log: LogDTO
    
    var sectionCount: Int {
        return self.log.memo.isEmptyOrNil ? 2 : 3
    }
    
    var topInfo: TopLogDetailCell.ViewData {
        return .init(name: self.log.username, amount: self.log.amount.currency ?? "error")
    }
    
    var narrowInfo: [NarrowLogDetailCell.ViewData] {
        var data: [NarrowLogDetailCell.ViewData] = []
        data.append(.init(title: LocalizableStrings.localize("created_date"), content: self.log.stringCreatedAt))
        return data
    }
    
    var wideInfo: [WideLogDetailCell.ViewData] {
        var data: [WideLogDetailCell.ViewData] = []
        if let memo = self.log.memo {
            data.append(.init(title: LocalizableStrings.localize("memo"), content: memo))
        }
        return data
    }
    
    init(log: LogDTO) {
        self.log = log
    }
}
