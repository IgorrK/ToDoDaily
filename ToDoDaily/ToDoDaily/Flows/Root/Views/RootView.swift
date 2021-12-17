//
//  RootView.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import SwiftUI

struct RootView: RoutableView {
    
    // MARK: - RoutableView
    
    let router: RootRouter
    @ObservedObject var viewModel: RootViewModel

    // MARK: - View
    
    var body: some View {
        switch viewModel.isLoggedIn {
        case true:
            router.view(for: .main)
        case false:
            router.view(for: .auth)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        let services = MockServices()
        RootView(router: RootRouter(services: services), viewModel: RootViewModel(services: services))
    }
}
