//
//  ProfileViewModel.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 21.12.2021.
//

import SwiftUI
import Combine
import Model
import Validation

final class ProfileViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var input: Input
    var user: User
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        self.input = Input(user: user)
    }
    
}

// MARK: - InteractiveViewModel
extension ProfileViewModel: InteractiveViewModel {
    enum Event {
        case done
    }
    
    func handleInput(event: Event) {
        
    }
}

// MARK: - Input
extension ProfileViewModel {
    final class Input: ObservableObject {
        
        // MARK: - Properties
        
        @Published var name: String
        
        // MARK: - Lifecycle
        
        init(user: User) {
            self.name = user.name
        }
        
        // MARK: - Validation
                
        lazy var nameValidation: Validation.Publisher = {
            $name.nonEmptyValidator("Name cannot be empty")
        }()
    }
}
