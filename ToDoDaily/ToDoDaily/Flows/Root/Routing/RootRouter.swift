//
//  RootRouter.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation
import SwiftUI
import Model

enum RootRoute: RouteType {
    case auth
    case onboarding
    case main
}

struct RootRouter: Routing {
    
    // MARK: - Properties
    
    var services: Services
    
    // MARK: - Routing
    
    func view(for route: RootRoute) -> some View {
        switch route {
        case .auth:
            LoginView.instance(with: services)
        case.onboarding:
            NavigationView {
                ProfileView(viewModel: ProfileViewModel(services: services))
            }
        case .main:
            MainView.instance(with: services)
        }
    }
}
