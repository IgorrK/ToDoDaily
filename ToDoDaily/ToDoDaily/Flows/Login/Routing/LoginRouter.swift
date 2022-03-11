//
//  LoginRouter.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 09.03.2022.
//

import Foundation
import SwiftUI
import Model

enum LoginRoute: RouteType {
    case goOffline
}

struct LoginRouter: Routing {
    
    // MARK: - Properties
    
    var services: Services
    
    // MARK: - Routing
    
    func view(for route: LoginRoute) -> some View {
        switch route {
        case .goOffline:
            NavigationView {
                ProfileView(viewModel: ProfileViewModel(services: services))
            }
        }
    }
}

