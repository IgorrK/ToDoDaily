//
//  SettingsView.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 01.01.2022.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Properties
    
    let router: SettingsRouter
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showsProfile = false
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            List {
                ForEach(Array(viewModel.menuItems.enumerated()), id: \.offset) { index, item in
                    Button(action: {
                        handleRowAction(item)
                    }, label: { SettingsRow(item: item) })
                }
                .listRowBackground(Asset.Colors.listRowBackground.color)                
            }
            .navigationTitle(L10n.Settings.title)
            .background(
                NavigationLink(destination: router.view(for: .profile(viewModel.user!)), isActive: $showsProfile, label: {})
            )
            .onAppear {
                UITableView.appearance().backgroundColor = Asset.Colors.primaryBackground.uiColor
                UITableView.appearance().separatorColor = Asset.Colors.listSeparator.uiColor
            }
        }
    }
}

// MARK: - Private methods
private extension SettingsView {
    func handleRowAction(_ item: SettingsItem) {
        switch item {
        case .editProfile:
            showsProfile.toggle()
        case .logOut:
            viewModel.handleInput(event: .logOut)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(router: SettingsRouter(services: AppServices()),
                     viewModel: SettingsViewModel(services: AppServices()))
    }
}
