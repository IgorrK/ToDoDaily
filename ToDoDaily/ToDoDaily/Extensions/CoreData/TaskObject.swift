//
//  TaskObject.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 28.01.2022.
//

import Foundation
import CoreData
import Model

// MARK: - `TaskPresentation` mapping

extension TaskObject {
    func asPresentation() throws -> TaskPresentation {
        return try TaskPresentation(managedObject: self)
    }
}

extension Array where Element == TaskObject {
    func mapToPresentationModels() throws -> [TaskPresentation] {
        return try self.map({ try $0.asPresentation() })
    }
}

// MARK: - Init and update with `Model.TaskItem`

extension TaskObject {

    static func newInstance(context: NSManagedObjectContext) -> Self {
        let instance = Self(context: context)
        instance.id = UUID()
        instance.createdAt = Date()
        return instance
    }
    
    static func newInstance(with presentation: TaskPresentation, context: NSManagedObjectContext) -> Self {
        let instance = Self(context: context)
        instance.id = UUID(uuidString: presentation.id)
        let createdAt = Date()
        instance.createdAt = createdAt
        instance.updatedAt = createdAt
        return instance
    }
    
//    static func newInstance(with model: TaskItem, context: NSManagedObjectContext) -> Self {
//        let instance = Self(context: context)
//        instance.id = UUID(uuidString: model.id)
//        instance.createdAt = model.createdAt
//        instance.update(with: model)
//        return instance
//    }
    
    func update(with model: TaskItem) {
        text = model.text
        dueDate = model.dueDate
        if let notificationId = model.notificationId {
            self.notificationId = UUID(uuidString: notificationId)
        }
        isDone = model.isDone
        updatedAt = model.updatedAt
    }
}

// MARK: - Encodable

extension TaskObject: DataFormatsEncodable {
    enum CodingKeys: String, CodingKey {
    
        case id
        case createdAt
        case dueDate
        case notificationId
        case text
        case isDone
        case updatedAt
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let id = try self.id.unwrap().uuidString
        let createdAt = try self.createdAt.unwrap()
        let text = try self.text.unwrap()
        
        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(dueDate, forKey: .dueDate)
        try container.encodeIfPresent(notificationId?.uuidString, forKey: .notificationId)
        try container.encode(text, forKey: .text)
        try container.encode(isDone, forKey: .isDone)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }
}
