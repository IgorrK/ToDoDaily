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
                List(viewModel.tasks) { task in
                    Text(task.text ?? "").onTapGesture {
                        viewModel.handleInput(event: .onTaskSelection(task))
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button(action: { isAddTaskPresented.toggle() }) {
                    Image(systemName: SFSymbols.plus)
                }
                .frame(width: 50.0, height: 50.0)
                .padding(.trailing, 28.0)
                .padding(.bottom, 20.0)
                .buttonStyle(CircularButtonStyle())
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Tasks")
            .navigationBarItems(trailing: NavigationLink(destination: router.view(for: .settings),
                                                         label: { Image(systemName: SFSymbols.gear) }))
            .onAppear(perform: { viewModel.handleInput(event: .onAppear) })
            .sheet(isPresented: $isAddTaskPresented) {
                router.view(for: .addTask)
            }
            .sheet(isPresented: $viewModel.showsDetailView, content: {
                if let selectedTask = viewModel.selectedTask {
                    TaskDetailsView(viewModel: TaskDetailsViewModel(displayMode: .details(selectedTask)))
                } else {
                    EmptyView()
                }
            })
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
                .overlay(Asset.Colors.secondaryShadow
                            .color.opacity(configuration.isPressed ? 0.2 : 0.0))
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
