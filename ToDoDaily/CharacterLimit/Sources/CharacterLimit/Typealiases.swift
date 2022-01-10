//
//  Typealiases.swift
//  
//
//  Created by Igor Kulik on 13.12.2021.
//

import Foundation
import Combine

public extension CharacterLimit {
    typealias Publisher = AnyPublisher<CharacterLimit.Status, Never>
}
