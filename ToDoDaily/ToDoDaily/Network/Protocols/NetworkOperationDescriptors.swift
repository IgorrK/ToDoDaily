//
//  NetworkOperationDescriptors.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 21.01.2022.
//

import Foundation

protocol CollectionListenerDescriptor {
    associatedtype ResponseType: Decodable
    
    var collectionName: String { get }
}

protocol UpdateOperationDescriptor {

    var collectionName: String { get }
    var documentId: String { get }
    var parameters: JSONDictionary { get }
}
