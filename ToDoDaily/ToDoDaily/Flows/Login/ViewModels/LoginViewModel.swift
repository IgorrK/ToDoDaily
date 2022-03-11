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
    @Published var isLoading: Bool = false
    @Published var isProfilePresented: Bool = false
    
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
            isProfilePresented.toggle()
        }
    }
    
    // MARK: - Private methods
    
    private func setBindings() {
        services.authManager.dataContainer.$error
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.error = value
            }
            .store(in: &self.anyCancellables)
        
        services.authManager.dataContainer.$isLoading.sink { [weak self] value in
            ConsoleLogger.shared.log(value)
            self?.isLoading = value
        }.store(in: &anyCancellables)
        
    }
}

extension LoginViewModel {
    enum Event {
        case onGoogleSignIn
        case onGoOffline
    }
}
