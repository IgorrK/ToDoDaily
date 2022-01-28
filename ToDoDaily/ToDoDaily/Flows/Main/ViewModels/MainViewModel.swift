//
//  MainViewModel.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 01.01.2022.
//

import Foundation
import SwiftUI
import Combine
import Model

final class MainViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    @Published var tasks = [TaskPresentation]()
    @Published var showsDetailView = false
    @Published var selectedTask: TaskPresentation? = nil
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
    
    private var networkManager: MainNetworking
    
    let dataStorage: TaskDataStorage
    
    // MARK: - Lifecycle
    
    init(services: Services, dataStorage: TaskDataStorage) {
        let preferencesContainer = PreferencesContainer(defaultsManager: services.defaultsManager)
        self.preferencesContainer = preferencesContainer
        self.layoutType = preferencesContainer.layoutType
        self.filterType = preferencesContainer.filterType
        self.networkManager = services.networkManager
        self.dataStorage = dataStorage
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
                sSelf.refineData(with: searchTerm, filterType: sSelf.filterType)
            }
            .store(in: &anyCancellables)
        
        preferencesContainer.$filterType
            .dropFirst()
            .sink { [weak self] filterType in
                guard let sSelf = self else { return }
                sSelf.refineData(with: sSelf.searchTerm, filterType: filterType)
            }
            .store(in: &anyCancellables)
        
        dataStorage.$tasks.sink { [weak self] taskObjects in
            do {
                self?.tasks = try taskObjects.mapToPresentationModels()
            } catch {
                ConsoleLogger.shared.log(error, logLevel: .error)
            }
            
        }.store(in: &anyCancellables)
    }
    
    func showDetails(task: TaskPresentation) {
        selectedTask = task
        showsDetailView = true
    }
    
    func complete(task: TaskPresentation) {
        do {
            try dataStorage.completeTask(id: task.id)
            isAnimatingTaskCompletion.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.isAnimatingTaskCompletion.toggle()
            }
        } catch {
            ConsoleLogger.shared.log("error saving task:", error, logLevel: .error)
        }
    }
    
    func copy(task: TaskPresentation) {
        UIPasteboard.general.string = task.text
    }
    
    func remove(task: TaskPresentation) {
        do {
            try dataStorage.removeTask(id: task.id)
        } catch {
            ConsoleLogger.shared.log("error deleting task:", error, logLevel: .error)
        }
    }
    
    func switchLayout() {
        guard let nextLayout = LayoutType(rawValue: layoutType.rawValue + 1) ?? LayoutType(rawValue: 0) else {
            return
        }
        layoutType = nextLayout
    }
    
    func refineData(with searchTerm: String, filterType: FilterType) {
        let predicate = Self.compoundPredicate(searchTerm: searchTerm, filterType: filterType)
        dataStorage.refine(with: predicate)
    }
    
    static func compoundPredicate(searchTerm: String, filterType: FilterType) -> NSPredicate? {
        guard !searchTerm.isEmpty else { return filterType.predicate }
        
        let searchTermPredicate = NSPredicate(format:"text contains[cd] %@", searchTerm)
        if let filterPredicate = filterType.predicate {
            return NSCompoundPredicate(andPredicateWithSubpredicates: [filterPredicate, searchTermPredicate])
        } else {
            return searchTermPredicate
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
        case taskSelected(TaskPresentation)
        case completeTask(TaskPresentation)
        case editTask(TaskPresentation)
        case copyTask(TaskPresentation)
        case removeTask(TaskPresentation)
        case switchLayout
    }
    
    func handleInput(event: Event) {
        switch event {
        case .onAppear:
            refineData(with: searchTerm, filterType: filterType)
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
