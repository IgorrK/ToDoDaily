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
import CoreData
import SwiftUI
import PermissionManager
import UserNotifications

final class TaskDetailsViewModel: ObservableObject {
    
    // MARK: - Properties
    
    private var managedObjectContext: NSManagedObjectContext { Environment(\.managedObjectContext).wrappedValue }
    
    @Published var input: Input
    
    private var anyCancellables = Set<AnyCancellable>()
    private let displayMode: DisplayMode
    
    var title: String { displayMode.title }
    var saveButtonTitle: String { displayMode.saveButtonTitle }
    private var task: TaskItem?
    
    // MARK: - Lifecycle
    
    init(displayMode: DisplayMode) {
        self.displayMode = displayMode
        switch displayMode {
        case .addTask:
            self.input = Input()
        case .details(let taskItem):
            self.task = taskItem
            self.input = Input(task: taskItem)
        }
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
        case details(TaskItem)
        
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
        let task: TaskItem = {
            if let existingTask = self.task {
                return existingTask
            } else {
                let task = TaskItem(context: managedObjectContext)
                task.id = UUID()
                task.createdAt = Date()
                return task
            }
        }()
        
        task.text = input.descriptionText
        
        if let existingNotificationId = task.notificationId {
            cancelNotification(id: existingNotificationId.uuidString)
        }
        
        if input.isDueDateEnabled {
            task.dueDate = input.dueDate
            
            if input.isNotificationEnabled {
                task.notificationId = scheduleNotification(for: task)
            }
        }
        
        do {
            try managedObjectContext.save()
            ConsoleLogger.shared.log("...success")
        } catch {
            ConsoleLogger.shared.log("error saving entity:", error)
        }
    }
    
    func completeTask() {
        task?.isDone = true
        do {
            try managedObjectContext.save()
            ConsoleLogger.shared.log("...success")
        } catch {
            ConsoleLogger.shared.log("error saving entity:", error)
        }
    }
    
    func scheduleNotification(for task: TaskItem) -> UUID? {
        guard let dueDate = task.dueDate else {
            return nil
        }
        let content = UNMutableNotificationContent()
        content.subtitle = task.text ?? ""
        content.sound = UNNotificationSound.default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = UUID()
        
        let request = UNNotificationRequest(identifier: identifier.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
        return identifier
    }
    
    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func deleteExistingTask() {
        if let task = task {
            managedObjectContext.delete(task)
            do {
                try managedObjectContext.save()
                ConsoleLogger.shared.log("...success")
            } catch {
                ConsoleLogger.shared.log("error deleting entity:", error)
            }
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
        
        init(task: TaskItem) {
            self.isDeleteEnabled = true
            
            if let descriptionText = task.text,
               !descriptionText.isEmpty {
                self.descriptionText = descriptionText
                self.isSaveEnabled = true
            } else {
                self.descriptionText = ""
                self.isSaveEnabled = false
            }
            
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
