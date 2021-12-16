//
//  ToDoDailyApp.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 16.12.2021.
//

import SwiftUI

@main
struct ToDoDailyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
