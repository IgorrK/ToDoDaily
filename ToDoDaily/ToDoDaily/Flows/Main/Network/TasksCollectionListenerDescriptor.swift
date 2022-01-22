//
//  TasksCollectionListenerDescriptor.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 21.01.2022.
//

import Foundation
import Model

struct TasksCollectionListenerDescriptor: CollectionListenerDescriptor {
    
    // MARK: - CollectionListenerDescriptor
    
    typealias ResponseType = Model.TaskItem
    
    var collectionName: String { "tasks" }
}
