//
//  MainView.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import SwiftUI

struct MainView: View {
    
    // MARK: - Properties
    
    let router: MainRouter
    @ObservedObject var viewModel: MainViewModel
    @State private var isAddTaskPresented = false
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Asset.Colors.primaryBackground.color
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible())],
                              spacing: 8.0) {
                        
                        ForEach($viewModel.tasks, id:\.self) { $item in
                            Button(action: processInput(.taskSelected(item))) {
                                TaskListCell(task: $item)
                            }
                            .buttonStyle(.plain)
                            .contextMenu { contextMenu(for: item) }
                        }
                    }
                              .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.linear, value: viewModel.tasks)
                
                Button(action: { isAddTaskPresented.toggle() }) {
                    Image(systemName: SFSymbols.plus)
                }
                .frame(width: 50.0, height: 50.0)
                .padding(.trailing, 28.0)
                .padding(.bottom, 20.0)
                .buttonStyle(CircularButtonStyle())
                
                if viewModel.isAnimatingTaskCompletion {
                    TaskCompletedView()
                }
            }
            .animation(.linear, value: viewModel.isAnimatingTaskCompletion)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(L10n.Main.title)
            .navigationBarItems(trailing: NavigationLink(destination: router.view(for: .settings),
                                                         label: { Image(systemName: SFSymbols.gear) }))
            .onAppear(perform: processInput(.onAppear))
            .sheet(isPresented: $isAddTaskPresented) {
                router.view(for: .addTask)
            }
            .sheet(isPresented: $viewModel.showsDetailView) {
                if let selectedTask = viewModel.selectedTask {
                    TaskDetailsView(viewModel: TaskDetailsViewModel(displayMode: .details(selectedTask)))
                } else {
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - Subviews
private extension MainView {
    @ViewBuilder
    func contextMenu(for item: TaskItem) -> some View {
        Button(action: processInput(.completeTask(item))) {
            Label(L10n.Main.complete, systemImage: SFSymbols.Checkmark.default)
        }
        .foregroundColor(Asset.Colors.green.color)
        
        Button(action: processInput(.editTask(item))) {
            Label(L10n.Main.edit, systemImage: SFSymbols.Square.And.pencil)
        }
        
        Button(action: processInput(.copyTask(item))) {
            Label(L10n.Main.copy, systemImage: SFSymbols.Doc.On.doc)
        }
        
        if #available(iOS 15.0, *) {
            Button(role: .destructive,
                   action: processInput(.removeTask(item))) {
                Label(L10n.Main.remove, systemImage: SFSymbols.trash)
            }
        } else {
            Button(action: processInput(.removeTask(item))) {
                Label(L10n.Main.remove, systemImage: SFSymbols.trash)
            }
        }
    }
}

// MARK: - Private methods
private extension MainView {
    func processInput(_ event: MainViewModel.Event) -> EmptyCallback {
        return {
            viewModel.handleInput(event: event)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(router: MainRouter(services: AppServices()), viewModel: MainViewModel())
    }
}


fileprivate struct CircularButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            
            Asset.Colors.secondaryButtonBackground.color
                .secondaryShadowStyle()
                .overlay(Asset.Colors.secondaryShadow.color
                            .opacity(configuration.isPressed ? 0.2 : 0.0))
                .clipShape(Circle())
            
            HStack {
                
                Spacer()
                
                configuration.label
                    .font(.system(size: 26.0, weight: .bold))
                    .foregroundColor(Asset.Colors.secondaryButtonForeground.color)
                
                Spacer()
            }
        }
        .background(Asset.Colors.secondaryButtonBackground.color
                        .clipShape(Circle())
                        .secondaryShadowStyle())
    }
}
