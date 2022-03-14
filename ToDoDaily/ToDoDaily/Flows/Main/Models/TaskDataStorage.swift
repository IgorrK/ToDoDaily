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
import Combine
import FirebaseFirestore


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
    
    private var anyCancellables = Set<AnyCancellable>()
    private let userId: String
    
    // MARK: - Lifecycle
    
    init(user: Model.User, networkManager: MainNetworking) {
        self.networkManager = networkManager
        self.userId = user.id
        super.init()
        setBindings()
    }
    
    // MARK: - Public methods
    
    func loadData() {
        fetchData()
    }
    
    func refine(with predicate: NSPredicate?) {
        let userIdPredicate = NSPredicate(format: "userId = %@", userId)
        let resultingPredicate: NSPredicate
        if let refinePredicate = predicate {
            resultingPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userIdPredicate, refinePredicate])
        } else {
            resultingPredicate = userIdPredicate
        }
        filterPredicate = resultingPredicate
        fetchedResultsController.fetchRequest.predicate = resultingPredicate
        fetchData()
    }
    
    func completeTask(id: String) throws {
        let object = try managedObjectContext.fetch(entity: TaskObject.self, id: id)
        object.isDone = true
        object.updatedAt = Date()
        try managedObjectContext.save()
        try updateRemoteTask(id: id, with: object)
    }
    
    func removeTask(id: String) throws {
        let object = try managedObjectContext.fetch(entity: TaskObject.self, id: id)
        managedObjectContext.delete(object)
        try managedObjectContext.save()
        
        networkManager.deleteTask(id: id).sink(receiveCompletion: { result in
            switch result {
            case .failure(let error):
                ConsoleLogger.shared.log(error, logLevel: .error)
            default:
                break
            }
        }, receiveValue: {})
            .store(in: &anyCancellables)
    }
    
    func newTaskPresentation() -> TaskPresentation {
        return TaskPresentation(userId: userId)
    }
    
    func updateTask(using presentation: TaskPresentation) throws {
        let object: TaskObject = {
            if let existingObject = try? managedObjectContext.fetch(entity: TaskObject.self, id: presentation.id) {
                return existingObject
            } else {
                let newObject = TaskObject.newInstance(with: presentation, context: managedObjectContext)
                return newObject
            }
        }()
        
        object.text = presentation.text
        object.dueDate = presentation.dueDate
        if let notificationId = presentation.notificationId {
            object.notificationId = UUID(uuidString: notificationId)
        }
        object.isDone = presentation.isDone
        object.updatedAt = Date()
        object.userId = presentation.userId
        try managedObjectContext.save()
        try updateRemoteTask(id: presentation.id, with: object)
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
    
    private func setBindings() {
        networkManager.tasksCollectionListener(userId: userId).sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                ConsoleLogger.shared.log("Network error:", error, logLevel: .error)
            default:
                break
            }
        }, receiveValue: { [weak self] models in
            self?.store(models)
        })
            .store(in: &anyCancellables)
    }
    
    private func store(_ models: [Model.TaskItem]) {
        do {
            let identifiers = try models.map({ try UUID(uuidString: $0.id).unwrap() })

            let existingObjects = try managedObjectContext.fetch(entity: TaskObject.self,
                                                                 predicate: NSPredicate(format: "id IN %@", identifiers))
            
            models.forEach { model in
                let object = existingObjects.first(where: { $0.id?.uuidString == model.id })
                let resolution = TaskModelVersionResolver.resolveVersionBetween(remoteModel: model, localModel: object)
                performResolution(resolution)
            }
            
            try managedObjectContext.save()
        } catch {
            ConsoleLogger.shared.log("Error storing `TaskItem` response:", error, logLevel: .error)
        }
    }
    
    private func performResolution(_ resolution: TaskModelVersionResolver.Resolution) {
        switch resolution {
        case .createAndUpdateLocal(let remoteModel):
            let object = TaskObject.newInstance(context: managedObjectContext)
            object.update(with: remoteModel)
            
        case .updateLocal(let remoteModel, let localObject):
            localObject.update(with: remoteModel)
            
        case .updateRemote(let remoteModel, let localObject):
            do {
                try updateRemoteTask(id: remoteModel.id, with: localObject)
            } catch {
                ConsoleLogger.shared.log(error, logLevel: .error)
            }
        case .notNeeded:
            ConsoleLogger.shared.log("Version resolution not needed")
        }
    }
    
    private func updateRemoteTask(id: String, with localObject: TaskObject) throws {
        let jsonObject = try localObject.asJsonObject()
        networkManager.updateTask(id: id, with: jsonObject).sink(receiveCompletion: { result in
            switch result {
            case .failure(let error):
                ConsoleLogger.shared.log(error, logLevel: .error)
            default:
                break
            }
        }, receiveValue: {})
            .store(in: &anyCancellables)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TaskDataStorage: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let objects = controller.fetchedObjects as? [TaskObject] else { return }
        tasks = objects
    }
}


fileprivate class TaskModelVersionResolver {
    
    // MARK: - Nested types
    
    enum Resolution {
        case createAndUpdateLocal(TaskItem)
        case updateLocal(TaskItem, TaskObject)
        case updateRemote(TaskItem, TaskObject)
        case notNeeded
    }
    
    // MARK: - Public methods
    
    static func resolveVersionBetween(remoteModel: TaskItem, localModel: TaskObject?) -> Resolution {
        guard let localModel = localModel else {
            return .createAndUpdateLocal(remoteModel)
        }
        
        let localUpdatedAt = localModel.updatedAt ?? Date(timeIntervalSince1970: 0.0)
        let remoteUpdatedAt = remoteModel.updatedAt
        
        switch Calendar.current.compare(localUpdatedAt, to: remoteUpdatedAt, toGranularity: .second) {
        case .orderedSame:
            return .notNeeded
        case .orderedDescending:
            return .updateRemote(remoteModel, localModel)
        case .orderedAscending:
            return .updateLocal(remoteModel, localModel)
        }
    }
}
