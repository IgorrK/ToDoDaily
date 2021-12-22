//
//  ProfileView.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 21.12.2021.
//

import SwiftUI
import Model

struct ProfileView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ProfileViewModel
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your name:")) {
                    TextField("Name:", text: $viewModel.input.name)
                        .validation(viewModel.input.nameValidation)
                }
            }
            .navigationBarTitle("Your Profile")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel(user: Model.User.mockUser))
    }
}

