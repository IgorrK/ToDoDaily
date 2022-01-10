//
//  Status.swift
//  
//
//  Created by Igor Kulik on 13.12.2021.
//

import Foundation

public extension CharacterLimit {
    
    enum Status {
        case initial
        case success(characterCount: Int, limit: Int)
        case failure(characterCount: Int, limit: Int)
        
        public var isSuccess: Bool {
            if case .success = self {
                return true
            }
            return false
        }
    }
}
