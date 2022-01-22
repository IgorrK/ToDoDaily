//
//  Optional.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 21.01.2022.
//

import Foundation

enum UnwrapError: Error {
    case unexpectedNil(file: String, line: Int, function: String)
    case unexpectedValue(file: String, line: Int, function: String)
}

extension UnwrapError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case let .unexpectedNil(file, line, function):
            return "Unexpectedly found nil at: \(file.components(separatedBy: "/").last!): line \(line) in \(function)"
        case let .unexpectedValue(file, line, function):
            return "Unexpectedly found value at: \(file.components(separatedBy: "/").last!): line \(line) in \(function)"
        }
    }
}

// MARK: - Defines convenience methods that throw errors when unexpected nil or value is wrapped into `Optional`.
extension Optional {
    func unwrap(file: String = #file, line: Int = #line, function: String = #function) throws -> Wrapped {
        return try unwrap(or: UnwrapError.unexpectedNil(file: file, line: line, function: function))
    }
    
    func unwrap(or error: @autoclosure () -> Error) throws -> Wrapped {
        switch self {
        case .some(let w): return w
        case .none: throw error()
        }
    }
    
    func checkIfNil(file: String = #file, line: Int = #line, function: String = #function) throws {
        return try checkIfNil(or: UnwrapError.unexpectedValue(file: file, line: line, function: function))
    }
    
    func checkIfNil(or error: @autoclosure () -> Error) throws {
        switch self {
        case .some: throw error()
        case .none: break
        }
    }
}
