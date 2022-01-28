//
//  NSManagedObjectContext.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 24.01.2022.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    func fetch<Entity: NSManagedObject>(entity: Entity.Type,
                                        predicate: NSPredicate? = nil,
                                        sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Entity] {
        
        let fetchRequest = Entity.fetchRequest()
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        let result = try self.fetch(fetchRequest)
        return try (result as? [Entity]).unwrap()
    }
    
    func fetch<Entity: NSManagedObject>(entity: Entity.Type,
                                        id: String) throws -> Entity {
        let result = try fetch(entity: Entity.self, predicate: NSPredicate(format: "id = %@", id))
        return try result.first.unwrap()
    }
}
