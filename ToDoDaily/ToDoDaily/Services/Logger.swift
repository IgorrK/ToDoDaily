//
//  Logger.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 18.12.2021.
//

import Foundation


protocol Logger {
    func log(_ items: Any...)
}

final class ConsoleLogger: Logger {
    
    // MARK: - Properties
    
    static let shared = ConsoleLogger()
    
    // MARK: - Logger
    
    func log(_ items: Any...) {
        print(items)
    }
}
