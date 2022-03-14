//
//  DeleteTaskOperationDescriptor.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 14.03.2022.
//

import Foundation

struct DeleteTaskOperationDescriptor: DeleteOperationDescriptor {
    
    // MARK: - UpdateOperationDescriptor
    
    var collectionName: String { "tasks" }
    
    var documentId: String

}
