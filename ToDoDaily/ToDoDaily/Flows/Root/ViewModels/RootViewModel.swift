//
//  RootViewModel.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation
import SwiftUI
import Combine
import Model

final class RootViewModel: ObservableObject {

    // MARK: - Propertes
 
    private let services: Services

    private var anyCancellables = Set<AnyCancellable>()

    @Published var state: State = .notAuthorized
    
    // MARK: - Lifecycle
    
    init(services: Services) {
        self.services = services
        setBindings()
    }
    
    // MARK: - Private methods
    
    private func setBindings() {
        self.services.authManager.dataContainer.$state.sink { [weak self] value in
            withAnimation {
                switch value {
                case .notAuthorized:
                    self?.state = .notAuthorized
                case .authorizedNewUser(let user):
                    self?.state = .newUser(user)
                case .authorizedExistingUser:
                    self?.state = .authorized
                }
            }
        }.store(in: &self.anyCancellables)
    }
    
    // MARK: - Public methods
    
    func logIn() {
        services.authManager.logIn()
    }
}

// MARK: - Nested types
extension RootViewModel {
    enum State  {
        case notAuthorized
        case newUser(User)
        case authorized
    }
}
