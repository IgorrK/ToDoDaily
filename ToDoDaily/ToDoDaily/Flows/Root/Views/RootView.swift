//
//  RootView.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import SwiftUI

struct RootView: View, RoutableView {
    
    // MARK: - RoutableView
    
    let router: RootRouter
    @ObservedObject var viewModel: RootViewModel
    
    // MARK: - View
    
    var body: some View {
        switch viewModel.state {
        case .notAuthorized:
            router.view(for: .auth)
        case .newUser(let user):
            router.view(for: .onboarding(user))
                .transition(.move(edge: .bottom))
        case .authorized:
            router.view(for: .main)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        let services = MockServices()
        RootView(router: RootRouter(services: services), viewModel: RootViewModel(services: services))
    }
}
