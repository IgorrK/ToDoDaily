//
//  File.swift
//  
//
//  Created by Igor Kulik on 21.12.2021.
//

import Foundation

public struct User: Equatable, Hashable {
    
    // MARK: - Properties
    
    public var id: String
    public var name: String
    public var photoURL: URL?
    
    // MARK: - Lifecycle
    
    public init(id: String, name: String, photoURL: URL?) {
        self.id = id
        self.name = name
        self.photoURL = photoURL
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
