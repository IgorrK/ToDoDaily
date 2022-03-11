//
//  AuthManager.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 10.03.2022.
//

import Foundation
import Model
import Combine

protocol AuthManager {
    var dataContainer: UserDataContainer { get }
    func logIn()
    func logOut()
    func updateCurrentUser(with user: Model.User) -> AnyPublisher<Model.User, Error>
}

final class MockAuthManager: AuthManager {
    
    var dataContainer: UserDataContainer = UserDataContainer()
    private let provider = MockAuthCredentialsProvider()
    
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
