//
//  LoginViewModel.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation

final class LoginViewModel: ObservableObject, InteractiveViewModel {

    // MARK: - Propertes
 
    private let services: Services

    // MARK: - Lifecycle
    
    init(services: Services) {
        self.services = services
    }

    // MARK: - InteractiveViewModel
    
    func handleInputEvent(_ event: Event) {
        switch event {
        case .onGoogleSignIn:
            services.authManager.logIn()
        case .onGoOffline:
            break
        }
    }
}

extension LoginViewModel {
    enum Event {
        case onGoogleSignIn
        case onGoOffline
    }
}
