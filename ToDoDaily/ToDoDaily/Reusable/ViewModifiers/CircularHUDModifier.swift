//
//  CircularHUDModifier.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 28.12.2021.
//

import Foundation
import SwiftUI
import Combine

struct CircularHUDModifier: ViewModifier {
    
    // MARK: - Properties
    
    private let manager: CircularHUDManager
    
    // MARK: - Lifecycle
    
    init(isShowing: Published<Bool>.Publisher, appStateContainer: AppStateContainer = Environment(\.appStateContainer).wrappedValue) {
        self.manager = CircularHUDManager(isShowing: isShowing, appStateContainer: appStateContainer)
    }

    
    // MARK: - ViewModifier

    func body(content: Content) -> some View {
        return content
    }
}

fileprivate class CircularHUDManager {
    
    // MARK: - Properties
    
    private var cancellable: AnyCancellable?
    private var appStateContainer: AppStateContainer

    
    // MARK: - Lifecycle
    
    init(isShowing: Published<Bool>.Publisher, appStateContainer: AppStateContainer) {
        self.appStateContainer = appStateContainer
        self.cancellable = isShowing.sink(receiveValue: { value in
            appStateContainer.hudState.showsHUD = value
        })
    }
}
