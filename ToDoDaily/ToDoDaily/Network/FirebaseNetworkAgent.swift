//
//  FirebaseNetworkAgent.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 21.01.2022.
//

import Foundation
import Combine
import FirebaseFirestore

struct FirebaseNetworkAgent: NetworkAgent {
    
    // MARK: - Properties
    
    private let jsonDecoder: JSONDecoder
    
    // MARK: - Lifecycle
    
    init(jsonDecoder: JSONDecoder = .defaultResponseDecoder) {
        self.jsonDecoder = jsonDecoder
    }
    
    // MARK: - NetworkAgent
    
    func run<Descriptor: CollectionListenerDescriptor>(descriptor: Descriptor) -> PassthroughSubject<[Descriptor.ResponseType], Swift.Error> {
        
        let subject = PassthroughSubject<[Descriptor.ResponseType], Swift.Error>()

        Firestore.firestore().collection(descriptor.collectionName).addSnapshotListener({ querySnapshot, error in
            if let error = error {
                subject.send(completion: .failure(error))
                return
            }
            
            let snapshot: QuerySnapshot
            do {
                snapshot = try querySnapshot.unwrap()
            } catch {
                subject.send(completion: .failure(error))
                return
            }
            
            do {
                let mappedResult = try snapshot.documents.map { document -> Descriptor.ResponseType in
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                    return try jsonDecoder.decode(Descriptor.ResponseType.self, from: jsonData)
                }
                subject.send(mappedResult)
            } catch {
                subject.send(completion: .failure(error))
            }
        })
        
        return subject
    }
}
