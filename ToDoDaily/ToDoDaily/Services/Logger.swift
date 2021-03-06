//
//  Logger.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 18.12.2021.
//

import Foundation
import SwiftyBeaver

enum LogLevel {
    case verbose    // The lowest priority level. Use this one for contextual information.
    case debug      // Use this level for printing variables and results that will help you fix a bug or solve a problem.
    case info       // This is typically used for information useful in a more general support context.
    case warning    // Used when reaching a condition that won’t necessarily cause a problem but leads the app in that direction.
    case error      // The most serious and highest priority log level. Use this only when your app has triggered a serious error.
}

protocol Logger {
    func log(_ items: Any..., logLevel: LogLevel, file: String, function: String, line: Int, context: Any?)
}

final class ConsoleLogger: Logger {
    
    // MARK: - Properties
    
    static let shared = ConsoleLogger()
    
    // MARK: - Lifecycle
    
    init() {
        let destination = ConsoleDestination()
        SwiftyBeaver.addDestination(destination)
    }
    
    
    // MARK: - Logger
    
    func log(_ items: Any..., logLevel: LogLevel = .debug, file: String = #file, function: String = #function, line: Int = #line, context: Any? = nil) {
        switch logLevel {
        case .verbose:
            SwiftyBeaver.verbose(items, file, function, line: line, context: context)
        case .debug:
            SwiftyBeaver.debug(items, file, function, line: line, context: context)
        case .info:
            SwiftyBeaver.info(items, file, function, line: line, context: context)
        case .warning:
            SwiftyBeaver.warning(items, file, function, line: line, context: context)
        case .error:
            SwiftyBeaver.error(items, file, function, line: line, context: context)
        }
    }
}
