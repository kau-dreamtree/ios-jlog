//
//  Log+CoreDataProperties.swift
//  JLog
//
//  Created by 이지수 on 7/7/24.
//
//

import Foundation
import CoreData


extension Log {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Log> {
        return NSFetchRequest<Log>(entityName: "Log")
    }

    @NSManaged public var id: Int64
    @NSManaged public var amount: Int32
    @NSManaged public var username: String
    @NSManaged public var memo: String?
    @NSManaged public var createdAt: Date

}

extension Log : Identifiable {

}
