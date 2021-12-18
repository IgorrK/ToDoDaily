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
}

final class AppServices: Services {
    var authManager: AuthManager
    var defaultsManager: DefaultsManager
        
    init() {
        self.defaultsManager = AppDefaultsManager()
        self.authManager = FirebaseAuthManager(defaultsManager: self.defaultsManager)
        
        FirebaseApp.configure()
    }
}

final class MockServices: Services {
    var defaultsManager: DefaultsManager = MockDefaultsManager()
    var authManager: AuthManager = MockAuthManager()
}
