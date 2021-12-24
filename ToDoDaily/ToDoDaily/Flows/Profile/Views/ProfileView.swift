//
//  ProfileView.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 21.12.2021.
//

import SwiftUI
import Model
import WebImage

struct ProfileView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ProfileViewModel
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            Form {
                HStack(alignment: .center) {
                    ZStack(alignment: .topTrailing) {
                        Button(action: {
                            ConsoleLogger.shared.log("onTap")
                        }, label: {
                            profileImage
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .frame(width: 160.0, height: 160.0, alignment: .center)
                                .secondaryShadowStyle()
                                .animation(.linear, value: viewModel.input.profileImage)
                        })
                            .buttonStyle(.plain)
                        
                        if viewModel.input.profileImage != nil {
                            Button(action: {
                                viewModel.handleInput(event: .setProfileImage(nil))
                            }, label: {
                                ZStack(alignment: .center) {
                                    Asset.Colors.red.color
                                        .clipShape(Circle())
                                        .frame(width: 32.0, height: 32.0)
                                        .secondaryShadowStyle()
                                    
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .font(.system(size: 10.0, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 16.0, height: 16.0)
                                }
                                
                            })
                                .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Section(header: Text("Your name:")) {
                    TextField("Name:", text: $viewModel.input.name)
                        .validation(viewModel.input.nameValidation)
                }
                
            }
            .navigationBarTitle("Your Profile")
            .onAppear { viewModel.handleInput(event: .onAppear) }
        }
    }
    
    @ViewBuilder
    private var profileImage: some View {
        if let profileImage = viewModel.input.profileImage {
            Image(uiImage: profileImage)
                .resizable()
        } else {
            Image(systemName: "person.crop.circle")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.secondary)
        }
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel(user: Model.User.mockUser))
    }
}

