//
//  File.swift
//  
//
//  Created by Igor Kulik on 13.12.2021.
//

import Foundation
import Combine

// MARK: - Publishers
extension Validation {
    
    public struct Publishers {
        static func nonEmptyValidation(for publisher: Published<String>.Publisher,
                                       errorMessage: String? = nil) -> Publisher {
            return publisher
                .debounce(for: 0.2, scheduler: RunLoop.main)
                .map { value in
                    if value.isEmpty {
                        return .failure(message: errorMessage ?? "")
                    } else {
                        return .success
                    }
                }
                .dropFirst()
                .eraseToAnyPublisher()
        }
        
        static func regexValidation(for publisher: Published<String>.Publisher,
                                    with pattern: String,
                                    errorMessage: String? = nil) -> Publisher {
            return publisher
                .debounce(for: 0.2, scheduler: RunLoop.main)
                .map { value in
                    let range = value.range(of: pattern, options: .regularExpression)
                    if range != nil {
                        return .success
                    } else {
                        return .failure(message: errorMessage ?? "")
                    }
                }
                .dropFirst()
                .eraseToAnyPublisher()
        }
        
        static func closureValidation<T>(for publisher: Published<T>.Publisher,
                                         closure: @escaping ValidationClosure<T>) -> Publisher {
            return publisher
                .debounce(for: 0.2, scheduler: RunLoop.main)
                .map { value in
                    closure(value)
                }
                .dropFirst()
                .eraseToAnyPublisher()
        }
        
        public static func validateLatest(_ a: Validation.Publisher,
                                           _ b: Validation.Publisher,
                                           
                                           errorMessage: String? = nil) -> Validation.Publisher {
            return Combine.Publishers.CombineLatest(a, b)
                .map { v1, v2 in
                    return [v1, v2].allSatisfy { $0.isSuccess } ? .success : .failure(message: errorMessage ?? "")
                }
                .eraseToAnyPublisher()
        }

        
        public static func validateLatest3(_ a: Validation.Publisher,
                                           _ b: Validation.Publisher,
                                           _ c: Validation.Publisher,
                                           errorMessage: String? = nil) -> Validation.Publisher {
            return Combine.Publishers.CombineLatest3(a, b, c)
                .map { v1, v2, v3 in
                    return [v1, v2, v3].allSatisfy { $0.isSuccess } ? .success : .failure(message: errorMessage ?? "")
                }
                .eraseToAnyPublisher()
        }
        
        public static func validateLatest4(_ a: Validation.Publisher,
                                           _ b: Validation.Publisher,
                                           _ c: Validation.Publisher,
                                           _ d: Validation.Publisher,
                                           errorMessage: String? = nil) -> Validation.Publisher {
            return Combine.Publishers.CombineLatest4(a, b, c, d)
                .map { v1, v2, v3, v4 in
                    return [v1, v2, v3, v4].allSatisfy { $0.isSuccess } ? .success : .failure(message: errorMessage ?? "")
                }
                .eraseToAnyPublisher()
        }

    }
}
