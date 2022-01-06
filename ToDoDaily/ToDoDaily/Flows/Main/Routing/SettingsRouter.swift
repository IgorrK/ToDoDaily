//
//  SettingsRouter.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 01.01.2022.
//

import Foundation
import SwiftUI
import Model

enum SettingsRoute: RouteType {
    case profile
}

struct SettingsRouter: Routing {
    
    // MARK: - Properties
    
    var services: Services
    
    // MARK: - Routing
    
    func view(for route: SettingsRoute) -> some View {
        switch route {
        case .profile:
            return ProfileView(viewModel: ProfileViewModel(services: services))
        }
    }
}
