//
//  LocalStorageManager.swift
//  JLog
//
//  Created by 이지수 on 7/7/24.
//

import Foundation
import CoreData

final actor LocalStorageManager {
    static let shared = LocalStorageManager()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "JLogModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    private init() {}
    
    func saveContext() -> Bool {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                return true
            } catch {
                let nserror = error as NSError
                return false
            }
        } else {
            return false
        }
    }
    
    func fetch<DTO: DTOConverter>() -> [DTO] {
        do {
//            let request = DTO.Origin.fetchRequest()
            let request = NSFetchRequest<DTO.Origin>(entityName: DTO.entityName)
            let fetchResult = try self.context.fetch(request) as! [DTO.Origin]
            return fetchResult.map(DTO.init)
        } catch {
            return []
        }
    }
    
    func insert<DTO: DTOConverter>(_ dto: DTO) -> Bool {
        guard let entity = NSEntityDescription.entity(forEntityName: DTO.entityName, in: self.context),
              var origin = NSManagedObject(entity: entity, insertInto: self.context) as? DTO.Origin else { return false }
        origin = dto.setValue(at: origin)
        return saveContext()
    }
    
    func deleteAll<DTO: DTOConverter>() -> [DTO] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: DTO.entityName)
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try self.context.execute(delete)
            return []
        } catch {
            return []
        }
    }
}
