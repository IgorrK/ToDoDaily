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

final class AddTaskViewModel: ObservableObject {

    // MARK: - Properties
    private var managedObjectContext: NSManagedObjectContext { Environment(\.managedObjectContext).wrappedValue }

    @Published var input = Input()

    private var anyCancellable: AnyCancellable? = nil

    // MARK: - Lifecycle
    
    init() {
        self.anyCancellable = input.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
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
                scheduleNotification(for: input.dueDate)
            }
        }
        
        do {
            try managedObjectContext.save()
            ConsoleLogger.shared.log("...success")
        } catch {
            ConsoleLogger.shared.log("error saving entity:", error)
        }
    }
    
    func scheduleNotification(for date: Date) {
        
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
