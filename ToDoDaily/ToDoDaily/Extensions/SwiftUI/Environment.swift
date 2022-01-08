//
//  Environment.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 28.12.2021.
//

import SwiftUI
import CoreData

struct AppStateContainerKey: EnvironmentKey {
    static let defaultValue: AppStateContainer = AppStateContainer()
}

struct UserDataContainerKey: EnvironmentKey {
    static let defaultValue: UserDataContainer = UserDataContainer()
}

struct ManagedObjectContextKey: EnvironmentKey {
    static let defaultValue: NSManagedObjectContext = PersistenceController.shared.container.viewContext
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
    
    var managedObjectContext: NSManagedObjectContext {
        get { self[ManagedObjectContextKey.self] }
    }

}
