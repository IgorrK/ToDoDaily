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
    
    private(set) var authMethod: AuthMethod
    var dataContainer: UserDataContainer { Environment(\.userDataContainer).wrappedValue}
    
    private var defaultsManager: DefaultsManager
    private var anyCancellables = Set<AnyCancellable>()
    private var credentialsProvider: AuthCredentialsProvider
    
    // MARK: - Lifecycle
    
    init(defaultsManager: DefaultsManager) {
        self.authMethod = .offline
        self.defaultsManager = defaultsManager
        self.credentialsProvider = OfflineAuthCredentialsProvider(defaultsManager: defaultsManager)
        setBindings()
        checkStoredAuth()
    }
    
    // MARK: - AuthManager
    
    func setAuthMethod(_ method: AuthMethod) {
        
        dataContainer.handle(event: .logOut)
        authMethod = method
        storedAuthMethod = method
        
        switch method {
        case .firebase:
            credentialsProvider = FirebaseAuthCredentialsProvider()
        case .offline:
            credentialsProvider = OfflineAuthCredentialsProvider(defaultsManager: defaultsManager)
        }
    }
    
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
            case .failure(let error):
                ConsoleLogger.shared.log(error)
            }
        }, receiveValue: {}).store(in: &anyCancellables)
    }
    
    func updateCurrentUser(with user: Model.User) -> AnyPublisher<Model.User, Swift.Error> {
        return credentialsProvider.updateCurrentUser(with: user)
    }
    
    // MARK: - Private methods
    
    var storedAuthMethod: AuthMethod {
        get {
            if let preferredAuthMethod: AuthMethod = defaultsManager.getDefault(.preferredAuthMethod) {
                return preferredAuthMethod
            } else {
                defaultsManager.setDefault(.preferredAuthMethod, value: AuthMethod.offline)
                return .offline
            }
        }
        set {
            defaultsManager.setDefault(.preferredAuthMethod, value: newValue)
        }
    }
    
    private func checkStoredAuth() {
        setAuthMethod(storedAuthMethod)
        
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
    }
}
