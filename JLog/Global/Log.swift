//
//  Log.swift
//  JLog
//
//  Created by 이지수 on 2/17/24.
//

import Foundation
import CoreData

protocol DTOConverter {
    associatedtype Origin: NSManagedObject
    static var entityName: String { get }
    
    var predicate: NSPredicate? { get }
    
    init(_: Origin)
    
    func setValue(at: Origin) -> Origin
}

struct LogDTO: Codable, DTOConverter {
    typealias Origin = Log
    
    static var entityName: String { "Log" }
    
    let id: Int64
    let amount: Int32
    let username: String
    let memo: String?
    let createdAt: Date
    
    var predicate: NSPredicate? {
        return NSPredicate(format: "id == %lld", self.id)
    }
    
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
    
    init(_ beforeDTO: LogDTO, amount: Int32, memo: String?) {
        self.id = beforeDTO.id
        self.amount = amount
        self.username = beforeDTO.username
        self.memo = memo
        self.createdAt = beforeDTO.createdAt
    }
    
    init(_ log: Log) {
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
    
    func setValue(at entity: Log) -> Log {
        entity.id = self.id
        entity.amount = self.amount
        entity.username = self.username
        entity.memo = self.memo
        entity.createdAt = self.createdAt
        return entity
    }
}

extension LogDTO: Comparable {
    static func < (lhs: LogDTO, rhs: LogDTO) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
}

struct BalanceDTO: Codable, DTOConverter, Equatable {
    typealias Origin = Balance
    
    static var entityName: String { "Balance" }
    
    let amount: Int64
    let username: String
    
    var predicate: NSPredicate? {
        return nil
    }
    
    init(amount: Int64, username: String) {
        self.amount = amount
        self.username = username
    }
    
    init(_ balance: Balance) {
        self.amount = balance.amount
        self.username = balance.username
    }
    
    func setValue(at entity: Balance) -> Balance {
        entity.setValue(self.amount, forKey: "amount")
        entity.setValue(self.username, forKey: "username")
        return entity
    }
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
