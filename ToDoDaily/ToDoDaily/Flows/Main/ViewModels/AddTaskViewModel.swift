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

final class AddTaskViewModel: ObservableObject {
    
    // MARK: - Properties
    private var managedObjectContext: NSManagedObjectContext { Environment(\.managedObjectContext).wrappedValue }
    
    @Published var input = Input()
    
    private var anyCancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    init() {
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
                            self?.input.isNotificationEnabled = true
                        case .denied,
                                .notNow:
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
extension AddTaskViewModel: InteractiveViewModel {
    enum Event: Hashable {
        case save
    }
    
    func handleInput(event: Event) {
        switch event {
        case .save:
            saveTaskFromInput()
        }
    }
}

// MARK: - Private methods
private extension AddTaskViewModel {
    func saveTaskFromInput() {
        let task = TaskItem(context: managedObjectContext)
        task.id = UUID()
        task.createdAt = Date()
        task.text = input.descriptionText
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
}

// MARK: - Input and Validation
extension AddTaskViewModel {
    final class Input: ObservableObject {
        
        // MARK: - Lifecycle
        
        @Published var descriptionText = ""
        
        @Published var isDueDateEnabled = false
        @Published var isNotificationEnabled = false
        @Published var dueDate = Date()
        @Published var isSaveEnabled = false
        @Published var showsPermissionDeniedAlert = false
        
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
    }
}
