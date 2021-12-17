//
//  AuthManager.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation
import Combine

public protocol AuthManager {
    var state: LoginState { get }
    func logIn()
    func logOut()
}

public class LoginState: ObservableObject {
    @Published var isLoggedIn: Bool = false
}

final class AppAuthManager: AuthManager {
    public var state: LoginState = LoginState()
    
    private var defaultsManager: DefaultsManager
    
    init(defaultsManager: DefaultsManager) {
        self.defaultsManager = defaultsManager
        
        setupValues()
    }
    
    private func setupValues() {
        state.isLoggedIn = self.defaultsManager.getDefault(.isLoggedIn)
    }
    
    public func logIn() {
        // TODO: Firebase sign-in
    }
    
    public func logOut() {
        state.isLoggedIn = false
        defaultsManager.setDefault(.isLoggedIn, value: true)
    }
}


final class MockAuthManager: AuthManager {
    var state: LoginState = LoginState()
    
    var didLogin = false
    var didLogOut = false
    
    func logIn() {
        didLogin = true
        state.isLoggedIn = true
    }

    func logOut() {
        didLogOut = true
        state.isLoggedIn = false
    }
    
}
