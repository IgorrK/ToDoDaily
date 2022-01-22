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
import Model

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
    @Published var isAnimatingTaskCompletion = false
    @Published var searchTerm = ""

    @Published var filterTypeDataSource = FilterType.allCases
    
    var preferencesContainer: PreferencesContainer
    
    var filterType: FilterType {
        didSet {
            preferencesContainer.filterType = filterType
        }
    }
    
    @Published var layoutType: LayoutType {
        didSet {
            preferencesContainer.layoutType = layoutType
        }
    }

    private var anyCancellables = Set<AnyCancellable>()
    
    private var networkClient: MainNetworking
    
    // MARK: - Lifecycle
    
    init(services: Services, networkClient: MainNetworking) {
        let preferencesContainer = PreferencesContainer(defaultsManager: services.defaultsManager)
        self.preferencesContainer = preferencesContainer
        self.layoutType = preferencesContainer.layoutType
        self.filterType = preferencesContainer.filterType
        self.networkClient = networkClient
        super.init()
        setBindings()
    }
}

// MARK: - Private methods

private extension MainViewModel {
    func setBindings() {
        $searchTerm
            .dropFirst()
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] searchTerm in
                guard let sSelf = self else { return }
                
                var predicate: NSPredicate?
                if !searchTerm.isEmpty {
                    let searchTermPredicate = sSelf.searchPredicate(for: searchTerm)
                    
                    if let filterPredicate = sSelf.filterType.predicate {
                        predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filterPredicate, searchTermPredicate])
                    } else {
                        predicate = searchTermPredicate
                    }
                } else {
                    predicate = sSelf.filterType.predicate
                }
                sSelf.fetchedResultsController.fetchRequest.predicate = predicate
                sSelf.fetchTasks()
            }
            .store(in: &anyCancellables)

        preferencesContainer.$filterType
            .dropFirst()
            .sink { [weak self] filterType in
                guard let sSelf = self else { return }

                var predicate: NSPredicate?
                if !sSelf.searchTerm.isEmpty {
                    let searchTermPredicate = sSelf.searchPredicate(for: sSelf.searchTerm)
                    
                    if let filterPredicate = filterType.predicate {
                        predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filterPredicate, searchTermPredicate])
                    } else {
                        predicate = searchTermPredicate
                    }
                } else {
                    predicate = filterType.predicate
                }
                sSelf.fetchedResultsController.fetchRequest.predicate = predicate
                sSelf.fetchTasks()
            }
            .store(in: &anyCancellables)
        
        networkClient.tasksCollectionListener()
            .sink(receiveCompletion: { result in
                ConsoleLogger.shared.log("result:", result)
            }, receiveValue: { value in
                ConsoleLogger.shared.log("value:", value)
            })
            .store(in: &anyCancellables)
    }
    
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
            isAnimatingTaskCompletion.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.isAnimatingTaskCompletion.toggle()
            }
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
    
    func switchLayout() {
        guard let nextLayout = LayoutType(rawValue: layoutType.rawValue + 1) ?? LayoutType(rawValue: 0) else {
            return
        }
        layoutType = nextLayout
    }
    
    func searchPredicate(for searchTerm: String) -> NSPredicate {
        return NSPredicate(format:"text contains[cd] %@", searchTerm)
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

// MARK: - Nested types
extension MainViewModel {
    enum FilterType: Int, CaseIterable {
        case actual
        case completed
        case all
        
        fileprivate var predicate: NSPredicate? {
            switch self {
            case .actual:
                return NSPredicate(format: "isDone = NO OR isDone = nil")
            case .completed:
                return NSPredicate(format: "isDone = YES")
            case .all:
                return nil
            }
        }
    }
    
    enum LayoutType: Int, CaseIterable {
        case list
        case grid        
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
        case switchLayout
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
        case .switchLayout:
            switchLayout()
        }
    }
}
