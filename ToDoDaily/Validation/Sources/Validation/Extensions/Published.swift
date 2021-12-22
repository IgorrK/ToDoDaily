//
//  Published.swift
//  
//
//  Created by Igor Kulik on 11.12.2021.
//

import Foundation
import SwiftUI

public extension Published.Publisher where Value == String {
    func nonEmptyValidator(_ errorMessage: @autoclosure @escaping Validation.ErrorClosure) -> Validation.Publisher {
        return Validation.Publishers.nonEmptyValidation(for: self, errorMessage: errorMessage())
    }
    
    func nonEmptyValidator() -> Validation.Publisher {
        return Validation.Publishers.nonEmptyValidation(for: self)
    }
    
    func regexValidator(pattern: String, errorMessage: @autoclosure @escaping Validation.ErrorClosure) -> Validation.Publisher {
        return Validation.Publishers.regexValidation(for: self, with: pattern, errorMessage: errorMessage())
    }
    
    func regexValidator(pattern: String) -> Validation.Publisher {
        return Validation.Publishers.regexValidation(for: self, with: pattern)
    }
}

public extension Published.Publisher {
    func closureValidator(_ closure: @escaping Validation.ValidationClosure<Output>) -> Validation.Publisher {
        return Validation.Publishers.closureValidation(for: self, closure: closure)
    }
}
