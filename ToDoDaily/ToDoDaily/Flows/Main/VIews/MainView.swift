//
//  MainView.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import SwiftUI
import Grid

struct MainView: View {
    
    // MARK: - Properties
    
    let router: MainRouter
    @ObservedObject var viewModel: MainViewModel
    @State private var isAddTaskPresented = false
    @State private var selection: Int = 0
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Asset.Colors.primaryBackground.color
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    
                    ZStack {
                        Grid(viewModel.tasks, id:\.self) { item in
                            let binding = Binding(
                                get: { item },
                                set: { _ in }
                            )
                            
                            Button(action: processInput(.taskSelected(item))) {
                                TaskListCell(task: binding)
                            }
                            .buttonStyle(.plain)
                            .contextMenu { contextMenu(for: item) }
                            
                        }
                        .padding(.horizontal)
                        
                        .gridStyle(viewModel.layoutType.gridStyle)
                        .padding(.top, 60.0)
                        
                        // Top Layer (Header)
                        GeometryReader { gr in
                            
                            let offset: CGFloat = {
                                let delta = 44.0 + (UIApplication.shared.currentKeyWindow?.safeAreaInsets.top ?? 0.0)
                                let origin = gr.frame(in: .global).origin.y
                                guard origin < delta else { return 0.0 }
                                
                                if origin < 0.0 {
                                    return abs(origin) + delta
                                } else {
                                    return delta - origin
                                }
                            }()
                            
                            VStack {
                                header
                                    .offset(y: offset + 8.0)
                                
                                Spacer()
                            }
                        }
                        
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.linear, value: viewModel.tasks)
                .animation(.linear, value: viewModel.layoutType)
                
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
            .navigationBarItems(trailing: NavigationLink(destination: router.view(for: .settings)
                                                            .navigationBarTitleDisplayMode(.large),
                                                         label: { Image(systemName: SFSymbols.gear) }))
            .onAppear {
                UITextField.appearance().clearButtonMode = .whileEditing
                viewModel.handleInput(event: .onAppear)
            }
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
    
    @ViewBuilder
    var header: some View {
        HStack {
            HStack {
                TextField("", text: $viewModel.searchTerm)
                    .placeholderStyle(when: viewModel.searchTerm.isEmpty,
                                      placeholder: {
                        Text(L10n.Main.searchBarPlaceholder)
                            .foregroundColor(.primary.opacity(0.65))
                    })
                
                Button(action: {
                    viewModel.handleInput(event: .switchLayout)
                }) {
                    Image(systemName: viewModel.layoutType.iconName)
                        .renderingMode(.template)
                        .foregroundColor(Asset.Colors.secondaryButtonForeground.color)
                        .font(.system(size: 18.0, weight: .bold))
                }
                .foregroundColor(Color.primary)
                       
                Menu(content: {
                    Picker("", selection: $viewModel.filterType) {
                        ForEach(viewModel.filterTypeDataSource, id: \.self) { filterType in
                            Text(filterType.name).tag(filterType.rawValue)
                        }
                    }
                }, label: {
                    Image(systemName: SFSymbols.Line.Three.Horizontal.Decrease.circle)
                        .renderingMode(.template)
                        .foregroundColor(Asset.Colors.secondaryButtonForeground.color)
                        .font(.system(size: 20.0, weight: .bold))
                })
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .frame(height: 44.0)
            .background(
                Asset.Colors.overlayBackground.color
                    .clipShape(RoundedRectangle(cornerRadius: 8.0, style: .continuous))
                    .secondaryShadowStyle()
            )
        }
        .padding(.horizontal, 26.0)
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
        MainView(router: MainRouter(services: MockServices()),
                 viewModel: MainViewModel(services: MockServices(), networkClient: MockServices().networkManager))
    }
}

fileprivate struct CircularButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            
            Asset.Colors.overlayBackground.color
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

fileprivate extension MainViewModel.FilterType {
    var name: String {
        switch self {
        case .actual:
            return L10n.Main.Filter.actual
        case .completed:
            return L10n.Main.Filter.completed
        case .all:
            return L10n.Main.Filter.all
        }
    }
}

fileprivate extension MainViewModel.LayoutType {
    var iconName: String {
        switch self {
        case .list:
            return SFSymbols.Rectangle.Grid.oneByTwo
        case .grid:
            return SFSymbols.Rectangle.Grid.twoByTwo
        }
    }
    
    var gridStyle: some GridStyle {
        switch self {
        case .list:
            return StaggeredGridStyle(.vertical, tracks: 1, spacing: 8.0)
        case .grid:
            return StaggeredGridStyle(.vertical, tracks: 2, spacing: 8.0)
        }
    }
}
