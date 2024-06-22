//
//  LogDetailViewModel.swift
//  JLog
//
//  Created by 이지수 on 6/22/24.
//

import Foundation

struct LogDetailViewModel: LogDetailViewModelProtocol {
    
    private let log: Log
    
    var sectionCount: Int {
        return self.log.memo.isEmptyOrNil ? 2 : 3
    }
    
    var topInfo: TopLogDetailCell.ViewData {
        return .init(name: self.log.username, amount: self.log.amount.currency ?? "error")
    }
    
    var narrowInfo: [NarrowLogDetailCell.ViewData] {
        var data: [NarrowLogDetailCell.ViewData] = []
        data.append(.init(title: "생성일", content: self.log.stringCreatedAt))
        return data
    }
    
    var wideInfo: [WideLogDetailCell.ViewData] {
        var data: [WideLogDetailCell.ViewData] = []
        if let memo = self.log.memo {
            data.append(.init(title: "메모", content: memo))
        }
        return data
    }
    
    init(log: Log) {
        self.log = log
    }
}
