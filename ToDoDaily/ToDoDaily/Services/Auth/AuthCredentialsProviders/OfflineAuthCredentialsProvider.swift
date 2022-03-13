//
//  OfflineAuthCredentialsProvider.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 11.03.2022.
//

import Foundation
import Combine
import Model

final class OfflineAuthCredentialsProvider: AuthCredentialsProvider {
    
    // MARK: - Properties
    
    private var defaultsManager: DefaultsManager

    // MARK: - Lifecycle
    
    init(defaultsManager: DefaultsManager) {
        self.defaultsManager = defaultsManager
    }
    
    // MARK: - AuthCredentialsProvider
    
    var method: AuthMethod { .firebase }
    var activityPublisher = PassthroughSubject<Bool, Never>()
    
    func checkExistingUser() -> AnyPublisher<User?, Never> {
        return Future<User?, Never> { [weak self] promise in
            promise(.success(self?.defaultsManager.getDefault(.currentUser)))
        }.eraseToAnyPublisher()
    }
    
    func logIn() -> AnyPublisher<User, Error> {
        return Future<User, Error> { [weak self] promise in
            let user = User(id: UUID().uuidString, name: "", photoURL: nil)
            self?.defaultsManager.setDefault(.currentUser, value: user)
            promise(.success(user))
        }.eraseToAnyPublisher()
    }
    
    func logOut() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            self?.defaultsManager.removeDefault(.currentUser)
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    func updateCurrentUser(with user: User) -> AnyPublisher<User, Error> {
        return Future<User, Error> { [weak self] promise in
            self?.defaultsManager.setDefault(.currentUser, value: user)
            promise(.success((user)))
        }.eraseToAnyPublisher()
    }
}
