//
//  RootViewModel.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation
import SwiftUI
import Combine

final class RootViewModel: ObservableObject {

    // MARK: - Propertes
 
    private let services: Services

    private var anyCancellables = Set<AnyCancellable>()

    @Published var isLoggedIn: Bool = false
    
    // MARK: - Lifecycle
    
    init(services: Services) {
        self.services = services
        setBindings()
    }
    
    // MARK: - Private methods
    
    private func setBindings() {
        self.services.authManager.state.$isLoggedIn.sink { [weak self] value in
            self?.isLoggedIn = value
        }.store(in: &self.anyCancellables)
    }
    
    // MARK: - Public methods
    
    func logIn() {
        services.authManager.logIn()
    }
}
