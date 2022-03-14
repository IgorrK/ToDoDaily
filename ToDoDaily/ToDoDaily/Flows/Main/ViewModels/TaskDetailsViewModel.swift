//
//  AddTaskViewModel.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 10.01.2022.
//

import Foundation
import Validation
import CharacterLimit
import Combine
import SwiftUI
import PermissionManager

final class TaskDetailsViewModel: ObservableObject {
    
    // MARK: - Properties
        
    @Published var input: Input
    
    private var anyCancellables = Set<AnyCancellable>()
    private let displayMode: DisplayMode
    
    var title: String { displayMode.title }
    var saveButtonTitle: String { displayMode.saveButtonTitle }
    private var task: TaskPresentation?
    let dataStorage: TaskDataStorage
    
    // MARK: - Lifecycle
    
    init(displayMode: DisplayMode, dataStorage: TaskDataStorage) {
        self.displayMode = displayMode
        switch displayMode {
        case .addTask:
            self.input = Input()
        case .details(let taskItem):
            self.task = taskItem
            self.input = Input(task: taskItem)
        }
        self.dataStorage = dataStorage
        setBindings()
    }
    
    // MARK: - Private methods
    
    private func setBindings() {
        input.objectWillChange
            .sink { _ in
                DispatchQueue.main.async { [weak self] in
                    self?.objectWillChange.send()
                }
            }
            .store(in: &anyCancellables)
        
        input.$isNotificationEnabled
            .dropFirst()
            .sink { value in
                guard value else { return }
                PermissionManager.resolvePermission(for: .userNotifications, completion: { status in
                    DispatchQueue.main.async { [weak self] in
                        switch status {
                        case .authorized:
                            break
                        case .denied, .notNow:
                            self?.input.isNotificationEnabled = false
                            self?.input.showsPermissionDeniedAlert.toggle()
                        }
                    }
                })
            }
            .store(in: &anyCancellables)
    }
}

// MARK: - InteractiveViewModel
extension TaskDetailsViewModel: InteractiveViewModel {
    enum Event: Hashable {
        case save
        case complete
        case delete
    }
    
    func handleInput(event: Event) {
        switch event {
        case .save:
            saveTaskFromInput()
        case .complete:
            completeTask()
        case .delete:
            deleteExistingTask()
        }
    }
}

// MARK: - Nested types
extension TaskDetailsViewModel {
    enum DisplayMode {
        case addTask
        case details(TaskPresentation)
        
        fileprivate var title: String {
            switch self {
            case .addTask:
                return L10n.TaskDetails.AddTask.title
            case .details:
                return L10n.TaskDetails.TaskDetails.title
            }
        }
        
        fileprivate var saveButtonTitle: String {
            switch self {
            case .addTask:
                return L10n.Application.save
            case .details:
                return L10n.Application.save
            }
        }
    }
}

// MARK: - Private methods
private extension TaskDetailsViewModel {
    func saveTaskFromInput() {
        var presentation: TaskPresentation = task ?? dataStorage.newTaskPresentation()
        
        presentation.text = input.descriptionText
        
        if let existingNotificationId = presentation.notificationId {
            NotificationScheduler.cancelNotification(id: existingNotificationId)
        }
        
        if input.isDueDateEnabled {
            presentation.dueDate = input.dueDate
            
            if input.isNotificationEnabled {
                presentation.notificationId = NotificationScheduler.scheduleNotification(for: presentation)?.uuidString
            }
        }
        
        do {
            try dataStorage.updateTask(using: presentation)
        } catch {
            ConsoleLogger.shared.log("error saving task:", error, logLevel: .error)
        }
    }
    
    func completeTask() {
        do {
            let task = try task.unwrap()
            try dataStorage.completeTask(id: task.id)
        } catch {
            ConsoleLogger.shared.log("error completing task:", error, logLevel: .error)
        }
    }
    
    func deleteExistingTask() {
        do {
            let task = try task.unwrap()
            try dataStorage.removeTask(id: task.id)
        } catch {
            ConsoleLogger.shared.log("error deleting task:", error, logLevel: .error)
        }
    }
}

// MARK: - Input and Validation
extension TaskDetailsViewModel {
    final class Input: ObservableObject {
        
        // MARK: - Lifecycle
        
        @Published var descriptionText = ""
        
        @Published var isDueDateEnabled = false
        @Published var isNotificationEnabled = false
        @Published var dueDate = Date()
        @Published var isSaveEnabled = false
        @Published var showsPermissionDeniedAlert = false
        @Published var isDeleteEnabled = false
        @Published var isCompleteEnabled = false

        var dueDateRange: PartialRangeFrom<Date>
                
        // MARK: - Validation
        
        lazy var descriptionTextValidation: Validation.Publisher = {
            $descriptionText.nonEmptyValidator("Task cannot be empty")
        }()
        
        lazy var descriptionTextCharacterLimit: CharacterLimit.Publisher = {
            $descriptionText.characterLimit(300)
        }()
        
        lazy var saveButtonValidation: Validation.Publisher = {
            descriptionTextValidation.eraseToAnyPublisher()
        }()
        
        // MARK: - Lifecycle
        
        init() {
            self.dueDateRange = Date()...
        }
        
        init(task: TaskPresentation) {
            self.isDeleteEnabled = true
            self.isCompleteEnabled = !task.isDone
            
            self.descriptionText = task.text
            self.isSaveEnabled = !task.text.isEmpty
            
            isNotificationEnabled = task.notificationId != nil
            if let dueDate = task.dueDate {
                isDueDateEnabled = true
                self.dueDate = dueDate
                self.dueDateRange = dueDate...
            } else {
                self.isDueDateEnabled = false
                self.dueDate = Date()
                self.dueDateRange = Date()...
            }
        }
    }
}
