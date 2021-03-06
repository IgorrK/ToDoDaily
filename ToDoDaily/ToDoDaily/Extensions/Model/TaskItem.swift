//
//  TaskItem.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 21.01.2022.
//

import Foundation
import Model

extension Model.TaskItem {
    
    // MARK: - Lifecycle
    
    init(managedObject: TaskObject) throws {
        let id = try managedObject.id.unwrap().uuidString
        let notificationId = try managedObject.notificationId.unwrap().uuidString
        let createdAt = try managedObject.createdAt.unwrap()
        let text = try managedObject.text.unwrap()
        let updatedAt = try managedObject.updatedAt.unwrap()
        let userId  = try managedObject.userId.unwrap()
        self.init(id: id,
                  createdAt: createdAt,
                  dueDate: managedObject.dueDate,
                  notificationId: notificationId,
                  isDone: managedObject.isDone,
                  text: text,
                  updatedAt: updatedAt,
                  userId: userId)
    }
}
