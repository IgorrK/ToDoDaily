//
//  MainViewModel.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 01.01.2022.
//

import Foundation
import SwiftUI
import Combine
import CoreData

final class MainViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private var managedObjectContext: NSManagedObjectContext { Environment(\.managedObjectContext).wrappedValue }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TaskItem> = {
        let fetchRequest = TaskItem.fetchRequest()
        fetchRequest.predicate = filterType.predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(TaskItem.createdAt), ascending: false)]
        
        let controller = NSFetchedResultsController<TaskItem>(fetchRequest: fetchRequest,
                                                              managedObjectContext: managedObjectContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    @Published var tasks = [TaskItem]()
    @Published var showsDetailView = false
    @Published var selectedTask: TaskItem? = nil
    @Published var filterType: FilterType
    
    // MARK: - Lifecycle
    
    init(filterType: FilterType = .onlyActual) {
        self.filterType = filterType
    }
}

// MARK: - Private methods

private extension MainViewModel {
    func fetchTasks() {
        do {
            try fetchedResultsController.performFetch()
            if let tasks = fetchedResultsController.fetchedObjects {
                self.tasks = tasks
            }
        } catch {
            ConsoleLogger.shared.log("fetching error:", error)
        }
    }
    
    func showDetails(task: TaskItem) {
        selectedTask = task
        showsDetailView = true
    }
    
    func complete(task: TaskItem) {
        task.isDone = true
        do {
            try managedObjectContext.save()
            ConsoleLogger.shared.log("...success")
        } catch {
            ConsoleLogger.shared.log("error saving entity:", error)
        }
    }
    
    func copy(task: TaskItem) {
        UIPasteboard.general.string = task.text
    }
    
    func remove(task: TaskItem) {
        managedObjectContext.delete(task)
        do {
            try managedObjectContext.save()
            ConsoleLogger.shared.log("...success")
        } catch {
            ConsoleLogger.shared.log("error deleting entity:", error)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension MainViewModel: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        ConsoleLogger.shared.log("controllerDidChangeContent")

        if let objects = controller.fetchedObjects as? [TaskItem] {
            tasks = objects
        }
    }
}

// MARK: - Nested types
extension MainViewModel {
    enum FilterType {
        case onlyActual
        case completed
        case all
        
        fileprivate var predicate: NSPredicate? {
            switch self {
            case .onlyActual:
                return NSPredicate(format: "isDone = NO OR isDone = nil")
            case .completed:
                return NSPredicate(format: "isDone = YES")
            case .all:
                return nil
            }
        }
    }
}

// MARK: - InteractiveViewModel
extension MainViewModel: InteractiveViewModel {
    enum Event: Hashable {
        case onAppear
        case taskSelected(TaskItem)
        case completeTask(TaskItem)
        case editTask(TaskItem)
        case copyTask(TaskItem)
        case removeTask(TaskItem)
        case onDelete(IndexSet)
    }
    
    func handleInput(event: Event) {
        switch event {
        case .onAppear:
            fetchTasks()
        case .taskSelected(let task):
            showDetails(task: task)
        case .completeTask(let task):
            complete(task: task)
        case .editTask(let task):
            showDetails(task: task)
        case .copyTask(let task):
            copy(task: task)
        case .removeTask(let task):
            remove(task: task)
        case .onDelete(let indexSet):
            ConsoleLogger.shared.log(indexSet)
        }
    }
}
