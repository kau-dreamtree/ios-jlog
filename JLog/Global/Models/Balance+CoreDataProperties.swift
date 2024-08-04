//
//  Balance+CoreDataProperties.swift
//  JLog
//
//  Created by 이지수 on 8/4/24.
//
//

import Foundation
import CoreData


extension Balance {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Balance> {
        return NSFetchRequest<Balance>(entityName: "Balance")
    }

    @NSManaged public var amount: Int64
    @NSManaged public var username: String

}

extension Balance : Identifiable {

}
