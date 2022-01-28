//
//  JSONEncoder.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 28.01.2022.
//

import Foundation

extension JSONEncoder {
    static var `default`: JSONEncoder {
        let decoder = JSONEncoder()
        decoder.dateEncodingStrategy = .secondsSince1970
        return decoder
    }
}
