//
//  UpdateTaskOperationDescriptor.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 28.01.2022.
//

import Foundation

struct UpdateTaskOperationDescriptor: UpdateOperationDescriptor {
    
    // MARK: - UpdateOperationDescriptor
    
    var collectionName: String { "tasks" }
    
    var documentId: String
    
    var parameters: JSONDictionary
    
}
