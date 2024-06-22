//
//  Log.swift
//  JLog
//
//  Created by 이지수 on 2/17/24.
//

import Foundation

struct Log: Codable {
    let id: Int
    let amount: Int
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
    
    var stringCreatedAt: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yy.MM.dd HH:mm"
        return dateFormatter.string(from: self.createdAt)
    }
}

struct Balance: Codable {
    let amount: Int
    let username: String
}

extension Int {
    var currency: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: self as NSNumber)
    }
}
