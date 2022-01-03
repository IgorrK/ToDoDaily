//
//  MainRouter.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 01.01.2022.
//

import Foundation
import SwiftUI
import Model

enum MainRoute: RouteType {
    case settings
}

struct MainRouter: Routing {
    
    // MARK: - Properties
    
    var services: Services
    
    // MARK: - Routing
    
    func view(for route: MainRoute) -> some View {
        switch route {
        case .settings:
            return SettingsView(router: SettingsRouter(services: services),
                                viewModel: SettingsViewModel(services: services))
        }
    }
}
