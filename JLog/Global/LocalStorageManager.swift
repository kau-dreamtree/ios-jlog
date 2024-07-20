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
    
    func fetch<DTO: DTOConverter>() -> DTO? {
        do {
//            let request = DTO.Origin.fetchRequest()
            let request = NSFetchRequest<DTO.Origin>(entityName: DTO.entityName)
            guard let fetchResult = (try self.context.fetch(request) as [DTO.Origin]).first else { return nil }
            return DTO.init(fetchResult)
        } catch {
            return nil
        }
    }
    
    @discardableResult
    func insert<DTO: DTOConverter>(_ dto: DTO) -> Bool {
        guard let entity = NSEntityDescription.entity(forEntityName: DTO.entityName, in: self.context),
              var origin = NSManagedObject(entity: entity, insertInto: self.context) as? DTO.Origin else { return false }
        origin = dto.setValue(at: origin)
        return saveContext()
    }
    
    @discardableResult
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
    
    @discardableResult
    func modify<DTO: DTOConverter>(to dto: DTO) -> DTO? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: DTO.entityName)
        request.predicate = dto.predicate
        do {
            guard var origin = try self.context.fetch(request).first as? DTO.Origin else { return nil }
            origin = dto.setValue(at: origin)
            try self.context.save()
            return dto
        } catch {
            return nil
        }
    }
    
    @discardableResult
    func delete<DTO: DTOConverter>(_ dto: DTO) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: DTO.entityName)
        request.predicate = dto.predicate
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try self.context.execute(delete)
            return true
        } catch {
            return false
        }
    }
}
