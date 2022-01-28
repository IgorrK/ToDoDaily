//
//  Encodable.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 28.01.2022.
//

import Foundation

protocol DataFormatsEncodable: Encodable {
    func asJsonObject() throws -> JSONDictionary
    func asData() throws -> Data
}

extension DataFormatsEncodable {
    
    func asJsonObject() throws -> JSONDictionary {
        let data = try asData()
        return try (JSONSerialization.jsonObject(with: data, options: .allowFragments) as? JSONDictionary).unwrap()
    }
    
    func asData() throws -> Data {
        return try JSONEncoder.default.encode(self)
    }
}
