//
//  Publishers.swift
//  
//
//  Created by Igor Kulik on 13.12.2021.
//

import Foundation
import Combine

// MARK: - Publishers
extension CharacterLimit {
    
    public struct Publishers {
        static func characterLimit(for publisher: Published<String>.Publisher,
                                characterLimit: Int) -> Publisher {
            return publisher
                .debounce(for: .zero, scheduler: RunLoop.main)
                .map { value in
                    if value.count > characterLimit {
                        return .failure(characterCount: value.count, limit: characterLimit)
                    } else {
                        return .success(characterCount: value.count, limit: characterLimit)
                    }
                }
                .dropFirst()
                .eraseToAnyPublisher()
        }
    }
}
