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
