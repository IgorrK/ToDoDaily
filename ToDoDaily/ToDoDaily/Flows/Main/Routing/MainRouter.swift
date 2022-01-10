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
    case addTask
}

struct MainRouter: Routing {
    
    // MARK: - Properties
    
    var services: Services
    
    // MARK: - Routing
    
    func view(for route: MainRoute) -> some View {
        switch route {
        case .settings:
            SettingsView(router: SettingsRouter(services: services),
                                viewModel: SettingsViewModel(services: services))
        case .addTask:
            AddTaskView(viewModel: AddTaskViewModel())
        }
    }
}
