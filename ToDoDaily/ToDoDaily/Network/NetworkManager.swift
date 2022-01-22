//
//  NetworkManager.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 28.12.2021.
//

import Foundation
import Combine

struct NetworkManager {
    
    // MARK: - Properties
        
    private let agent: NetworkAgent
    
    // MARK: - Lifecycle
    
    init(agent: NetworkAgent) {
        self.agent = agent
    }
    
    // MARK: - NetworkManager
        
    func collectionListener<Descriptor: CollectionListenerDescriptor>(_ descriptor: Descriptor) -> AnyPublisher<[Descriptor.ResponseType], Swift.Error> {
        return agent.run(descriptor: descriptor).eraseToAnyPublisher()
    }
}
