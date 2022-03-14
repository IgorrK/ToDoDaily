//
//  MockNetworkAgent.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 28.01.2022.
//

import Foundation
import Combine
import SwiftUI

struct MockNetworkAgent: NetworkAgent {
        
    // MARK: - NetworkAgent
    
    func run<Descriptor: CollectionListenerDescriptor>(descriptor: Descriptor) -> PassthroughSubject<[Descriptor.ResponseType], Error> {
        
        let subject = PassthroughSubject<[Descriptor.ResponseType], Swift.Error>()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            subject.send(completion: .finished)
        })
        return subject
    }
    
    func update<Descriptor>(descriptor: Descriptor) -> Future<Void, Error> where Descriptor : UpdateOperationDescriptor {
        return Future() { promise in
            promise(.success(()))
        }
    }
    
    func delete<Descriptor>(descriptor: Descriptor) -> Future<Void, Error> where Descriptor : DeleteOperationDescriptor {
        return Future() { promise in
            promise(.success(()))
        }
    }
}
