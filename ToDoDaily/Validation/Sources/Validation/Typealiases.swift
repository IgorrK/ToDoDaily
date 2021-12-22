//
//  File.swift
//  
//
//  Created by Igor Kulik on 11.12.2021.
//

import Foundation
import Combine

public extension Validation {
    typealias ValidationClosure<T> = (Published<T>.Publisher.Output) -> Validation.Status
    typealias ErrorClosure = () -> String
    typealias Publisher = AnyPublisher<Validation.Status, Never>
}
