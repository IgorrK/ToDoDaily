//
//  AuthCredentialsProvider.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 11.03.2022.
//

import Foundation
import Model
import Combine

protocol AuthCredentialsProvider {
    var method: AuthMethod { get }
    var activityPublisher: PassthroughSubject<Bool, Never> { get }

    func checkExistingUser() -> AnyPublisher<Model.User?, Never>
    func logIn() -> AnyPublisher<Model.User, Error>
    func logOut() -> AnyPublisher<Void, Error>
    func updateCurrentUser(with user: Model.User) -> AnyPublisher<Model.User, Error>
}

final class MockAuthCredentialsProvider: AuthCredentialsProvider {
    var method: AuthMethod { .offline }
    var activityPublisher = PassthroughSubject<Bool, Never>()
    
    var didLogin = false
    var didLogOut = false
    
    func checkExistingUser() -> AnyPublisher<Model.User?, Never> {
        return Future<Model.User?, Never>() { promise in
            promise(.success(User.mockUser))
        }.eraseToAnyPublisher()
    }
     
    func logIn() -> AnyPublisher<Model.User, Error> {
        didLogin = true
        return Future<Model.User, Error>() { promise in
            promise(.success(User.mockUser))
        }.eraseToAnyPublisher()
    }
    
    func logOut() -> AnyPublisher<Void, Error> {
        didLogOut = true
        return Future<Void, Error>() { promise in
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    func updateCurrentUser(with user: Model.User) -> AnyPublisher<Model.User, Error> {
        return Future<Model.User, Error>() { promise in
            promise(.success(user))
        }.eraseToAnyPublisher()
    }
}
