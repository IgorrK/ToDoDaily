//
//  ProfileView.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 21.12.2021.
//

import SwiftUI
import Model
import WebImage
import ImagePicker

struct ProfileView: View {
    
    // MARK: - Properties
    
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showsImagePicker = false
    
    // MARK: - View
    
    var body: some View {
            Form {
                HStack(alignment: .center) {
                    profileImageComponent
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .listRowBackground(Asset.Colors.listRowBackground.color)

                Section(header: Text(L10n.Profile.Name.header)) {
                    TextField(L10n.Profile.Name.placeholder, text: $viewModel.input.name)
                        .validation(viewModel.input.nameValidation)
                }
                .listRowBackground(Asset.Colors.listRowBackground.color)
            }
            .listRowBackground(Asset.Colors.listRowBackground.color)
            .navigationBarTitle(L10n.Profile.title)
            .navigationBarItems(trailing: doneButton.disabled(!viewModel.input.isDoneEnabled))
            .validation(viewModel.input.doneButtonValidation, flag: $viewModel.input.isDoneEnabled)
            .alert(error: $viewModel.error)
            .circularHUD(isShowing: viewModel.$isLoading)
            .imagePicker(isPresented: $showsImagePicker,
                         pickedImage: $viewModel.input.profileImage)
            .onAppear { viewModel.handleInput(event: .onAppear) }
            .onReceive(viewModel.viewDismissalPublisher, perform: { shouldDismiss in
                if shouldDismiss {
                    presentationMode.wrappedValue.dismiss()
                }
            })
    }
    
    @ViewBuilder
    private var profileImage: some View {
        if let profileImage = viewModel.input.profileImage {
            Image(uiImage: profileImage)
                .resizable()
        } else if let currentProfileImage = viewModel.currentProfileImage {
            Image(uiImage: currentProfileImage)
                .resizable()
        } else {
            Image(systemName: SFSymbols.Person.Crop.circle)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private var profileImageComponent: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                showsImagePicker.toggle()
            }, label: {
                profileImage
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .frame(width: 160.0, height: 160.0, alignment: .center)
                    .secondaryShadowStyle()
            })
                .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    private var doneButton: some View {
        Button(action: {
            viewModel.handleInput(event: .done)
        }, label: {
            Text(L10n.Application.done)
        })
    }

}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel(services: AppServices()))
    }
}

