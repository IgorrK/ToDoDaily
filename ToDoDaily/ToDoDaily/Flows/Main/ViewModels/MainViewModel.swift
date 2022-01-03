//
//  MainViewModel.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 01.01.2022.
//

import Foundation
import Combine

final class MainViewModel: ObservableObject {
    
}

// MARK: - InteractiveViewModel
extension MainViewModel: InteractiveViewModel {
    enum Event: Hashable {
        case onAppear
    }
    
    func handleInput(event: Event) {
        switch event {
        case .onAppear:
            break
        }
    }
}
