//
//  FirebaseAuthManager.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation
import Combine
import Model
import Firebase
import SwiftUI

final class AppAuthManager: AuthManager {
    
    // MARK: - Properties
    
    var dataContainer: UserDataContainer { Environment(\.userDataContainer).wrappedValue}
    
    private var defaultsManager: DefaultsManager
    private var anyCancellables = Set<AnyCancellable>()
    private let credentialsProvider: AuthCredentialsProvider
    
    // MARK: - Lifecycle
    
    init(defaultsManager: DefaultsManager) {
        self.defaultsManager = defaultsManager
        self.credentialsProvider = FirebaseAuthCredentialsProvider()
        setBindings()
        checkExistingUser()
    }
    
    // MARK: - AuthManager
    
    func logIn() {
        credentialsProvider.logIn().sink(receiveCompletion: { [weak self] result in
            switch result {
            case .failure(let error):
                self?.processError(error)
            default:
                break
            }
        }, receiveValue: { [weak self] user in
            self?.processLogIn(user)
        }).store(in: &anyCancellables)
    }
    
    func logOut() {
        credentialsProvider.logOut().sink(receiveCompletion: { [weak self] result in
            switch result {
            case .finished:
                self?.dataContainer.handle(event: .logOut)
                self?.defaultsManager.setDefault(.isLoggedIn, value: true)
            case .failure(let error):
                ConsoleLogger.shared.log(error)
            }
        }, receiveValue: {}).store(in: &anyCancellables)
    }
    
    func updateCurrentUser(with user: Model.User) -> AnyPublisher<Model.User, Swift.Error> {
        return credentialsProvider.updateCurrentUser(with: user)
    }
    
    // MARK: - Private methods
    
    private func checkExistingUser() {
        credentialsProvider.checkExistingUser().sink(receiveCompletion: { _ in },
                                          receiveValue: { [weak self] user in
            if let currentUser = user {
                self?.dataContainer.handle(event: .authorizedExistingUser(currentUser))
            }
        }).store(in: &anyCancellables)
    }
    
    private func setBindings() {
        credentialsProvider.activityPublisher.sink(receiveCompletion: { _ in },
                                        receiveValue: { [weak self] isLoading in
            self?.dataContainer.isLoading = isLoading
        }).store(in: &anyCancellables)
    }
    
    private func processError(_ error: Error) {
        dataContainer.handle(event: .error(error))
    }
    
    private func processLogIn(_ result: Model.User) {
        dataContainer.handle(event: .authorizedNewUser(result))
        defaultsManager.setDefault(.isLoggedIn, value: true)
    }
}
