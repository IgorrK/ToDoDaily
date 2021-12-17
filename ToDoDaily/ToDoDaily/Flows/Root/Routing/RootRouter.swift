//
//  RootRouter.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation
import SwiftUI

enum RootRoute: RouteType {
    case auth
    case main
}

struct RootRouter: Routing {

    // MARK: - Properties
    
    var services: Services
    
    // MARK: - Routing
    
    func view(for route: RootRoute) -> some View {
        switch route {
        case .auth:
            LoginView(viewModel: LoginViewModel(services: services))
        case .main:
            MainView()
        }
    }
}
