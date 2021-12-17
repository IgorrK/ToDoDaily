//
//  InteractiveViewModel.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 18.12.2021.
//

import Foundation

typealias EventType = Hashable

protocol InteractiveViewModel {
    associatedtype Event: EventType

    func handleInputEvent(_ event: Event)
}

