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
    
    let createdAt: Date
    var text: String
    var dueDate: Date?
    var notificationId: String?
    var isDone: Bool
    
    // MARK: - Lifecycle
    
    init(managedObject: TaskObject) throws {
        self.id = try managedObject.id.unwrap().uuidString
        self.createdAt = try managedObject.createdAt.unwrap()
        self.text = try managedObject.text.unwrap()
        self.dueDate = managedObject.dueDate
        self.notificationId = managedObject.notificationId?.uuidString
        self.isDone = managedObject.isDone
    }
    
    init() {
        self.id = UUID().uuidString
        self.createdAt = Date()
        self.text = ""
        self.isDone = false
    }
}
