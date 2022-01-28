//
//  TaskDataStorage.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 22.01.2022.
//

import Foundation
import SwiftUI
import CoreData
import Model

final class TaskDataStorage: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private var managedObjectContext: NSManagedObjectContext { Environment(\.managedObjectContext).wrappedValue }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TaskObject> = {
        let fetchRequest = TaskObject.fetchRequest()
        fetchRequest.predicate = filterPredicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(TaskObject.createdAt), ascending: false)]
        
        let controller = NSFetchedResultsController<TaskObject>(fetchRequest: fetchRequest,
                                                                managedObjectContext: managedObjectContext,
                                                                sectionNameKeyPath: nil,
                                                                cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    private var networkManager: MainNetworking
    
    @Published private(set) var tasks = [TaskObject]()
    
    private(set) var filterPredicate: NSPredicate?
    
    // MARK: - Lifecycle
    
    init(networkManager: MainNetworking, predicate: NSPredicate?) {
        self.networkManager = networkManager
        self.filterPredicate = predicate
        super.init()
    }
    
    // MARK: - Public methods
    
    func loadData() {
        fetchData()
    }
    
    func refine(with predicate: NSPredicate?) {
        filterPredicate = predicate
        fetchedResultsController.fetchRequest.predicate = predicate
        fetchData()
    }
    
    func completeTask(id: String) throws {
        let object = try managedObjectContext.fetch(entity: TaskObject.self, id: id)
        object.isDone = true
        try managedObjectContext.save()
    }
    
    func removeTask(id: String) throws {
        let object = try managedObjectContext.fetch(entity: TaskObject.self, id: id)
        managedObjectContext.delete(object)
        try managedObjectContext.save()
    }
    
    func updateTask(using presentation: TaskPresentation) throws {
        let object: TaskObject = {
            if let existingObject = try? managedObjectContext.fetch(entity: TaskObject.self, id: presentation.id) {
                return existingObject
            } else {
                let task = TaskObject(context: managedObjectContext)
                task.id = UUID(uuidString: presentation.id)
                task.createdAt = presentation.createdAt
                return task
            }
        }()
        
        object.text = presentation.text
        object.dueDate = presentation.dueDate
        if let notificationId = presentation.notificationId {
            object.notificationId = UUID(uuidString: notificationId)
        }
        object.isDone = presentation.isDone
        try managedObjectContext.save()
    }
    
    // MARK: - Private methods
    
    private func fetchData() {
        do {
            try fetchedResultsController.performFetch()
            tasks = try fetchedResultsController.fetchedObjects.unwrap()
        } catch {
            ConsoleLogger.shared.log("fetching error:", error)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TaskDataStorage: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let objects = controller.fetchedObjects as? [TaskObject] else { return }
        tasks = objects
    }
}
