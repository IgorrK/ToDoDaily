//
//  TaskItem.swift
//  
//
//  Created by Igor Kulik on 21.01.2022.
//

import Foundation

public struct TaskItem: Hashable, Codable {
    
    // MARK: - Properties
    
    public var id: String
    public var createdAt: Date
    public var dueDate: Date?
    public var notificationId: String?
    public var isDone: Bool
    public var text: String
    public var updatedAt: Date
    public var userId: String
    
    // MARK: - Lifecycle
    
    public init(id: String,
                createdAt: Date,
                dueDate: Date?,
                notificationId: String?,
                isDone: Bool,
                text: String,
                updatedAt: Date,
                userId: String) {
        self.id = id
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.notificationId = notificationId
        self.isDone = isDone
        self.text = text
        self.updatedAt = updatedAt
        self.userId = userId
    }
}
