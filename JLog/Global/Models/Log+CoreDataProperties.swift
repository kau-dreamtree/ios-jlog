//
//  Log+CoreDataProperties.swift
//  JLog
//
//  Created by 이지수 on 8/4/24.
//
//

import Foundation
import CoreData


extension Log {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Log> {
        return NSFetchRequest<Log>(entityName: "Log")
    }

    @NSManaged public var amount: Int32
    @NSManaged public var createdAt: Date
    @NSManaged public var id: Int64
    @NSManaged public var memo: String?
    @NSManaged public var username: String

}

extension Log : Identifiable {

}
