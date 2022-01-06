//
//  UserDataContainer.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 06.01.2022.
//

import Foundation
import SwiftUI
import Model

final class UserDataContainer: ObservableObject {
    
    // MARK: - Nested types
    
    enum State {
        case notAuthorized
        case authorizedNewUser(Model.User)
        case authorizedExistingUser(Model.User)
    }
    
    enum Event {
        case authorizedExistingUser(Model.User)
        case authorizedNewUser(Model.User)
        case updatedUserProfile(Model.User)
        case error(Error)
        case logOut
    }
    
    // MARK: - Properties
    
    @Published private(set) var state: State = .notAuthorized
    @Published var user: Model.User? = nil
    @Published var error: Error?
    @Published var isLoading: Bool = false
    
    // MARK: - Public methods
    
    func handle(event: Event) {
        switch (event, self.state) {
        case (.authorizedNewUser(let user), _):
            self.user = user
            self.state = .authorizedNewUser(user)
        case (.authorizedExistingUser(let user), _):
            self.user = user
            self.state = .authorizedExistingUser(user)
        case (.updatedUserProfile(let user), .authorizedNewUser):
            self.user = user
            self.state = .authorizedExistingUser(user)
        case (.updatedUserProfile(let user), .authorizedExistingUser):
            self.user = user
            self.state = .authorizedExistingUser(user)
        case (.error(let error), _):
            self.state = .notAuthorized
            self.error = error
        case (.logOut, _):
            self.state = .notAuthorized
            self.user = nil
        default:
            break
        }
    }
}
