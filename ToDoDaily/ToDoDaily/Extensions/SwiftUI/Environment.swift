//
//  Environment.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 28.12.2021.
//

import SwiftUI

struct AppStateContainerKey: EnvironmentKey {
    static let defaultValue: AppStateContainer = AppStateContainer()
}

struct UserDataContainerKey: EnvironmentKey {
    static let defaultValue: UserDataContainer = UserDataContainer()
}

extension EnvironmentValues {
    var appStateContainer: AppStateContainer {
        get { self[AppStateContainerKey.self] }
        set { self[AppStateContainerKey.self] = newValue }
    }
    
    var userDataContainer: UserDataContainer {
        get { self[UserDataContainerKey.self] }
        set { self[UserDataContainerKey.self] = newValue }
    }
}
