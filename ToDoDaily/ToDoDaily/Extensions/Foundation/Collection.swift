//
//  Collection.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 12.01.2022.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
