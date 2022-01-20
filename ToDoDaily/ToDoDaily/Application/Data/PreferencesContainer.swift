//
//  PreferencesContainer.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 20.01.2022.
//

import Foundation
import SwiftUI
import Model

final class PreferencesContainer: ObservableObject {
    
    // MARK: - Properties
    
    private var defaultsManager: DefaultsManager
    
    @Published var filterType: MainViewModel.FilterType {
        didSet {
            defaultsManager.setDefault(.taskListFilterType, value: filterType)
        }
    }
    
    @Published var layoutType: MainViewModel.LayoutType {
        didSet {
            defaultsManager.setDefault(.taskListLayoutType, value: layoutType)
        }
    }
    
    // MARK: - Lifecycle
    
    init(defaultsManager: DefaultsManager) {
        self.defaultsManager = defaultsManager
        self.filterType = {
            if let storedFilterType: MainViewModel.FilterType = defaultsManager.getDefault(.taskListFilterType) {
                return storedFilterType
            } else {
                let defaultFilterType: MainViewModel.FilterType = .actual
                defaultsManager.setDefault(.taskListFilterType, value: defaultFilterType)
                return defaultFilterType
            }
        }()
        
        self.layoutType = {
            if let storedLayoutType: MainViewModel.LayoutType = defaultsManager.getDefault(.taskListLayoutType) {
                return storedLayoutType
            } else {
                let defaultLayoutType: MainViewModel.LayoutType = .list
                defaultsManager.setDefault(.taskListLayoutType, value: defaultLayoutType)
                return defaultLayoutType
            }
        }()
    }
}
