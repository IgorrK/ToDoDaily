//
//  Services.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation
import Firebase

protocol Services {
    var defaultsManager: DefaultsManager { get }
    var authManager: AuthManager { get }
    var networkManager: NetworkManager { get }
}

final class AppServices: Services {
    var authManager: AuthManager
    var defaultsManager: DefaultsManager
    var networkManager: NetworkManager
        
    init() {
        FirebaseApp.configure()

        self.defaultsManager = AppDefaultsManager()
        self.authManager = AppAuthManager(defaultsManager: self.defaultsManager)
        self.networkManager = NetworkManager(agent: FirebaseNetworkAgent())
    }
}

final class MockServices: Services {
    var defaultsManager: DefaultsManager = MockDefaultsManager()
    var authManager: AuthManager = MockAuthManager()
    var networkManager: NetworkManager = NetworkManager(agent: FirebaseNetworkAgent())
}
