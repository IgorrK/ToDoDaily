//
//  FirebaseAPI.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 28.12.2021.
//

import Foundation
import Combine
import Model
import FirebaseAuth

struct FirebaseAPI {
    
    static func updateCurrentUser(with user: Model.User) -> AnyPublisher<Model.User, Swift.Error> {
        return Future<Model.User, Swift.Error>() { promise in
            guard let request = Auth.auth().currentUser?.createProfileChangeRequest() else {
                promise(.failure(Error.User.changeRequest))
                return
            }
            request.displayName = user.name
            let photoURL = URL(string: user.photoURL ?? "")
            request.photoURL = photoURL
            /// For some reason, it is impossible to clear user's photo, setiing `photoURL` to `nil` does nothing :/
            request.commitChanges(completion: { error in
                if let error = error {
                    promise(.failure(Error.User.commit(error)))
                } else {
                    promise(.success(user))
                }
            })
        }.eraseToAnyPublisher()
    }
}

// MARK: - Nested types
extension FirebaseAPI {
    struct Error {
        
        enum User: LocalizedError {
            case changeRequest
            case commit(Swift.Error)
            
            // MARK: - LocalizedError
            
            var errorDescription: String? {
                return L10n.APIErrors.User.description
            }
            
            var failureReason: String? {
                switch self {
                case .changeRequest:
                    return L10n.APIErrors.User.ChangeRequest.failureReason
                case .commit:
                    return L10n.APIErrors.User.Commit.failureReason
                }
            }
            
            var recoverySuggestion: String? {
                switch self {
                case .changeRequest:
                    return L10n.APIErrors.User.ChangeRequest.recoverySuggestion
                case .commit:
                    return L10n.APIErrors.User.Commit.recoverySuggestion
                }
            }
        }
    }
}
