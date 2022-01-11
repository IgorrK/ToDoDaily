//
//  AddTaskView.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 10.01.2022.
//

import SwiftUI

struct AddTaskView: View {
    
    // MARK: - Properties
    
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: AddTaskViewModel
        
    // MARK: - View
    
    var body: some View {
        NavigationView {
            Form {
                Section(footer: EmptyView()
                            .characterLimit(viewModel.input.descriptionTextCharacterLimit,
                                            text: $viewModel.input.descriptionText)) {
                    
                    /// Not sure if it's the best solution for placeholder
                    ZStack(alignment: .leading) {
                        if viewModel.input.descriptionText.isEmpty {
                            VStack(alignment: .leading) {
                                Text(L10n.AddTask.description)
                                    .opacity(0.5)
                                    .padding(.top, 8.0)
                                    .padding(.leading, 4.0)
                                
                                Spacer()
                            }
                        }
                        
                        TextEditor(text: $viewModel.input.descriptionText)
                            .validation(viewModel.input.descriptionTextValidation)
                            .frame(height: 120)
                    }
                }
                
                Section {
                    LazyVStack {
                        Toggle(L10n.AddTask.dueDate, isOn: $viewModel.input.isDueDateEnabled.animation())
                        
                        if viewModel.input.isDueDateEnabled {
                            
                            HStack {
                                Spacer()
                                DatePicker(L10n.AddTask.dueDate, selection: $viewModel.input.dueDate)
                                    .labelsHidden()
                            }
                            
                            Toggle(L10n.AddTask.notifyMe, isOn: $viewModel.input.isNotificationEnabled)
                            
                            
                        }
                    }
                }
            }
            .navigationBarTitle(L10n.AddTask.title)
            .navigationBarItems(trailing: saveButton.disabled(!viewModel.input.isSaveEnabled))
            .validation(viewModel.input.saveButtonValidation, flag: $viewModel.input.isSaveEnabled)
            .permissionDeniedAlert(permissionType: .userNotifications, isPresented: $viewModel.input.showsPermissionDeniedAlert)
        }
    }
}

// MARK: - Subviews
private extension AddTaskView {
    
    @ViewBuilder var saveButton: some View {
        Button(action: {
            viewModel.handleInput(event: .save)
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text(L10n.Application.save)
        })
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView(viewModel: AddTaskViewModel())
    }
}
