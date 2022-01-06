//
//  AppStateContainer.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 19.12.2021.
//

import Foundation
import SwiftUI

final class AppStateContainer: ObservableObject {
    
    var hudState = HUDState()
    
    final class HUDState: ObservableObject {
        @Published var showsHUD: Bool = false
    }
}

