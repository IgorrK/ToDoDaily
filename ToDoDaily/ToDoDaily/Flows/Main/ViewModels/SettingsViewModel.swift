//
//  SettingsViewModel.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 01.01.2022.
//

import Foundation
import Model

final class SettingsViewModel: ObservableObject {

    // MARK: - Properties
    
    private let services: Services
    var menuItems = SettingsItem.allCases

    @Published var user: Model.User?
    
    // MARK: - Lifecycle
    
    init(services: Services) {
        self.services = services
        self.user = services.authManager.dataContainer.user
    }
}

// MARK: - InteractiveViewModel
extension SettingsViewModel: InteractiveViewModel {
    enum Event: Hashable {
        case logOut
    }
    
    func handleInput(event: Event) {
        switch event {
        case .logOut:
            services.authManager.logOut()
        }
    }
}
