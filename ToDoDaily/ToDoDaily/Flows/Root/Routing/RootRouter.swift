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
    case onboarding(User)
    case main
}

struct RootRouter: Routing {
    
    // MARK: - Properties
    
    @EnvironmentObject var stateContainer: AppStateContainer
    var services: Services
    
    // MARK: - Routing
    
    func view(for route: RootRoute) -> some View {
        switch route {
        case .auth:
            LoginView(viewModel: LoginViewModel(services: services))
        case.onboarding(let user):
            ProfileView(viewModel: ProfileViewModel(user: user))
        case .main:
            MainView()
        }
    }
}
