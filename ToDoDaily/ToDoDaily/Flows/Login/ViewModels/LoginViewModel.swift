//
//  LoginViewModel.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation
import SwiftUI
import Combine

final class LoginViewModel: ObservableObject, InteractiveViewModel {
    
    // MARK: - Propertes
    
    private let services: Services
    
    private var anyCancellables = Set<AnyCancellable>()
    @Published var error: Error?
    
    // MARK: - Lifecycle
    
    init(services: Services) {
        self.services = services
        setBindings()
    }
    
    // MARK: - InteractiveViewModel
    
    func handleInput(event: Event) {
        switch event {
        case .onGoogleSignIn:
            services.authManager.logIn()
        case .onGoOffline:
            break
        }
    }
    
    // MARK: - Private methods
    
    private func setBindings() {
        self.services.authManager.dataContainer.$error
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.error = value
            }
            .store(in: &self.anyCancellables)
    }
    
    
    // MARK: - Public methods
    
    func bind(to appStateContainer: AppStateContainer) {
        services.authManager.dataContainer.$isLoading.sink { value in
            appStateContainer.hudState.showsHUD = value
        }.store(in: &anyCancellables)
    }
}

extension LoginViewModel {
    enum Event {
        case onGoogleSignIn
        case onGoOffline
    }
}
