//
//  TaskPresentation.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 28.01.2022.
//

import Foundation
import CoreData

struct TaskPresentation: Identifiable, Hashable {
    
    // MARK: - Identifiable
    
    let id: String
    
    // MARK: - Properties
    
    var text: String
    var dueDate: Date?
    var notificationId: String?
    var isDone: Bool
    var userId: String
    
    // MARK: - Lifecycle
    
    init(managedObject: TaskObject) throws {
        self.id = try managedObject.id.unwrap().uuidString
        self.text = try managedObject.text.unwrap()
        self.dueDate = managedObject.dueDate
        self.notificationId = managedObject.notificationId?.uuidString
        self.isDone = managedObject.isDone
        self.userId = try managedObject.userId.unwrap()
    }
    
    init(userId: String) {
        self.id = UUID().uuidString
        self.text = ""
        self.isDone = false
        self.userId = userId
    }
}
