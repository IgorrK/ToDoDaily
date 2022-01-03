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
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            VStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            }
            .navigationTitle("Tasks")
            .navigationBarItems(trailing: NavigationLink(destination: router.view(for: .settings),
                                                         label: { Image(systemName: SFSymbols.gear) }))
            .onAppear(perform: { viewModel.handleInput(event: .onAppear) })
            
        }
        
    }
}
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(router: MainRouter(services: AppServices()), viewModel: MainViewModel())
    }
}
