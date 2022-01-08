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
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(TaskItem.createdAt), ascending: false)]
        
        let controller = NSFetchedResultsController<TaskItem>(fetchRequest: fetchRequest,
                                                              managedObjectContext: managedObjectContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    @Published var tasks = [TaskItem]()
    
    // MARK: - Lifecycle
    
}

// MARK: - Private methods

private extension MainViewModel {
    func fetchTasks() {
        ConsoleLogger.shared.log("")
        do {
            try fetchedResultsController.performFetch()
            if let tasks = fetchedResultsController.fetchedObjects {
                self.tasks = tasks
            }
        } catch {
            ConsoleLogger.shared.log("fetching error:", error)
        }
    }
    
    func addTask() {
        ConsoleLogger.shared.log("Adding a task...")
        let testData = ["Clean the toilet", "Sniff some bebra", "Go outside", "Listen to Deftones", "Attend spaceship piloting courses"]
        let task = TaskItem(context: managedObjectContext)
        task.id = UUID()
        task.createdAt = Date()
        task.text = testData.randomElement()!
        do {
            try managedObjectContext.save()
            ConsoleLogger.shared.log("...success")
        } catch {
            ConsoleLogger.shared.log("error saving entity:", error)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension MainViewModel: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let objects = controller.fetchedObjects as? [TaskItem] {
            tasks = objects
        }
    }
}

// MARK: - InteractiveViewModel
extension MainViewModel: InteractiveViewModel {
    enum Event: Hashable {
        case onAppear
        case addTask
    }
    
    func handleInput(event: Event) {
        switch event {
        case .onAppear:
            fetchTasks()
        case .addTask:
            addTask()
        }
    }
}
