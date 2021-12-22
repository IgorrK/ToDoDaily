//
//  Status.swift
//  
//
//  Created by Igor Kulik on 13.12.2021.
//

import Foundation

public extension Validation {
    
    enum Status {
        case success
        case failure(message: String)
        
        public var isSuccess: Bool {
            if case .success = self {
                return true
            }
            return false
        }
    }
}
