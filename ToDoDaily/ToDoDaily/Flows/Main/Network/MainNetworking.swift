//
//  MainNetworking.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 21.01.2022.
//

import Foundation
import Model
import Combine

protocol MainNetworking {

    func tasksCollectionListener(userId: String) -> AnyPublisher<[Model.TaskItem], Swift.Error>
    
    func updateTask(id: String, with parameters: JSONDictionary) -> Future<Void, Error>
}

extension NetworkManager: MainNetworking {
    
    func tasksCollectionListener(userId: String) -> AnyPublisher<[Model.TaskItem], Swift.Error> {
        let descriptor = TasksCollectionListenerDescriptor(userId: userId)
        return collectionListener(descriptor)
    }
    
    func updateTask(id: String, with parameters: JSONDictionary) -> Future<Void, Error> {
        let descriptor = UpdateTaskOperationDescriptor(documentId: id, parameters: parameters)
        return update(descriptor: descriptor)
    }
}
