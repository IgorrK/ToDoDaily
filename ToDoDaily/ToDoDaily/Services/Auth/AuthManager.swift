//
//  AuthManager.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 10.03.2022.
//

import Foundation
import Model
import Combine

enum AuthMethod: Int, DefaultsStorable {
    case firebase
    case offline
}

protocol AuthManager {
    var authMethod: AuthMethod { get }
    var dataContainer: UserDataContainer { get }
    func setAuthMethod(_ method: AuthMethod)
    
    func logIn()
    func logOut()
    func updateCurrentUser(with user: Model.User) -> AnyPublisher<Model.User, Error>
}

final class MockAuthManager: AuthManager {
    
    var authMethod: AuthMethod { .offline }
    var dataContainer: UserDataContainer = UserDataContainer()
    private let provider = MockAuthCredentialsProvider()
    
    func setAuthMethod(_ method: AuthMethod) {}
    
    func logIn() {
        _ = provider.logIn()
        dataContainer.handle(event: .authorizedNewUser(Model.User.mockUser))
    }
    
    func logOut() {
        _ = provider.logOut()
        dataContainer.handle(event: .logOut)
    }
    
    func updateCurrentUser(with user: Model.User) -> AnyPublisher<Model.User, Error> {
        return provider.updateCurrentUser(with: user)
    }
}
