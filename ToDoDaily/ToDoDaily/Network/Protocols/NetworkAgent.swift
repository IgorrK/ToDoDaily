//
//  NetworkAgent.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 21.01.2022.
//

import Foundation
import Combine

protocol NetworkAgent {
    func run<Descriptor: CollectionListenerDescriptor>(descriptor: Descriptor) -> PassthroughSubject<[Descriptor.ResponseType], Error>
    func update<Descriptor: UpdateOperationDescriptor>(descriptor: Descriptor) -> Future<Void, Error>
    func delete<Descriptor: DeleteOperationDescriptor>(descriptor: Descriptor) -> Future<Void, Error>
}
