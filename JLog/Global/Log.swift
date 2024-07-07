//
//  Log.swift
//  JLog
//
//  Created by 이지수 on 2/17/24.
//

import Foundation

struct LogDTO: Codable {
    let id: Int64
    let amount: Int32
    let username: String
    let memo: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "log_id"
        case amount
        case username
        case memo
        case createdAt = "created_at"
    }
    
    init(id: Int64, amount: Int32, username: String, memo: String?, createdAt: Date) {
        self.id = id
        self.amount = amount
        self.username = username
        self.memo = memo
        self.createdAt = createdAt
    }
    
    init(log: Log) {
        self.id = log.id
        self.amount = log.amount
        self.username = log.username
        self.memo = log.memo
        self.createdAt = log.createdAt
    }
    
    var stringCreatedAt: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yy.MM.dd HH:mm"
        return dateFormatter.string(from: self.createdAt)
    }
}

struct BalanceDTO: Codable {
    let amount: Int32
    let username: String
}

extension Int32 {
    var currency: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: self as NSNumber)
    }
}

extension Int64 {
    var currency: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: self as NSNumber)
    }
}
