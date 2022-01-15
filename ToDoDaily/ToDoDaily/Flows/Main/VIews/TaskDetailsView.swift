//
//  AddTaskView.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 10.01.2022.
//

import SwiftUI

struct TaskDetailsView: View {
    
    // MARK: - Properties
    
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: TaskDetailsViewModel
    
    @State private var defaultFooterHeight = 0.0
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button(action: {
                        viewModel.handleInput(event: .complete)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text(L10n.TaskDetails.completeTask)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Image(systemName: SFSymbols.Checkmark.Circle.fill)
                                .renderingMode(.template)
                                .foregroundColor(Asset.Colors.green.color)
                                .font(.system(size: 24.0))
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(
                        Asset.Colors.listRowBackground.color
                            .overlay(Asset.Colors.green.color.opacity(0.2))
                    )
                }
                
                Section(footer: EmptyView()
                            .characterLimit(viewModel.input.descriptionTextCharacterLimit,
                                            text: $viewModel.input.descriptionText)) {
                    
                    /// Not sure if it's the best solution for placeholder
                    ZStack(alignment: .leading) {
                        if viewModel.input.descriptionText.isEmpty {
                            VStack(alignment: .leading) {
                                Text(L10n.TaskDetails.description)
                                    .opacity(0.5)
                                    .padding(.top, 8.0)
                                    .padding(.leading, 4.0)
                                
                                Spacer()
                            }
                        }
                        
                        TextEditor(text: $viewModel.input.descriptionText)
                            .validation(viewModel.input.descriptionTextValidation)
                            .frame(height: 120)
                            .padding(.horizontal, -8.0)
                    }
                }
                .listRowBackground(Asset.Colors.listRowBackground.color)
                
                Section {
                    LazyVStack {
                        Toggle(L10n.TaskDetails.dueDate, isOn: $viewModel.input.isDueDateEnabled.animation())
                        
                        if viewModel.input.isDueDateEnabled {
                            HStack {
                                Spacer()
                                DatePicker(L10n.TaskDetails.dueDate,
                                           selection: $viewModel.input.dueDate,
                                           in: viewModel.input.dueDateRange)
                                    .labelsHidden()
                            }
                            
                            Toggle(L10n.TaskDetails.notifyMe, isOn: $viewModel.input.isNotificationEnabled)
                        }
                    }
                }
                .listRowBackground(Asset.Colors.listRowBackground.color)
                
                footer
                    .listRowBackground(Color.clear)
            }
            .listRowBackground(Asset.Colors.listRowBackground.color)
            .navigationBarTitle(viewModel.title)
            .navigationBarItems(trailing: saveButton.disabled(!viewModel.input.isSaveEnabled))
            .validation(viewModel.input.saveButtonValidation, flag: $viewModel.input.isSaveEnabled)
            .permissionDeniedAlert(permissionType: .userNotifications, isPresented: $viewModel.input.showsPermissionDeniedAlert)
            .onAppear {
                UITableView.appearance().sectionFooterHeight = 0.0
            }
        }
    }
}

// MARK: - Subviews
private extension TaskDetailsView {
    
    @ViewBuilder var saveButton: some View {
        Button(action: {
            viewModel.handleInput(event: .save)
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text(viewModel.saveButtonTitle)
        })
    }
    
    @ViewBuilder var footer: some View {
        if viewModel.input.isDeleteEnabled {
            HStack(alignment: .center) {
                Spacer()
                Button(action: {
                    viewModel.handleInput(event: .delete)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(L10n.TaskDetails.removeTask)
                        .fontWeight(.medium)
                        .foregroundColor(Asset.Colors.red.color)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            .padding(.top, -20.0)
        } else {
            EmptyView()
        }
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailsView(viewModel: TaskDetailsViewModel(displayMode: .addTask))
    }
}
