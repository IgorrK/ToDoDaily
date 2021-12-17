//
//  ToDoDailyApp.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 16.12.2021.
//

import SwiftUI

@main
struct ToDoDailyApp: App {

    // MARK: - Propertise
    
    private let services: Services = MockServices()
    
    // MARK: - App
    
    var body: some Scene {
        WindowGroup {
            RootView(router: RootRouter(services: services), viewModel: RootViewModel(services: services))
        }
    }
}
