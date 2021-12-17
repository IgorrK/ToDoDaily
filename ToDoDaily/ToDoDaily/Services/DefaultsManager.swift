//
//  DefaultsManager.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation

enum DefaultsKey: String {
    case isLoggedIn
}

protocol DefaultsManager {
    func getDefault(_ key: DefaultsKey) -> Bool
    func setDefault(_ key: DefaultsKey, value: Bool)

    func getDefault(_ key: DefaultsKey) -> String?
    func setDefault(_ key: DefaultsKey, value: String)
}

final class AppDefaultsManager: DefaultsManager {

    func getDefault(_ key: DefaultsKey) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    func setDefault(_ key: DefaultsKey, value: Bool) {
        UserDefaults.standard.setValue(value, forKey: key.rawValue)
    }

    func getDefault(_ key: DefaultsKey) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }
    
    func setDefault(_ key: DefaultsKey, value: String) {
        UserDefaults.standard.setValue(value, forKey: key.rawValue)
    }
}

final class MockDefaultsManager: DefaultsManager {
    var didGetDefaultBool = false
    var didSetDefaultBool = false
    var didGetDefaultString = false
    var didSetDefaultString = false

    func getDefault(_ key: DefaultsKey) -> Bool {
        didGetDefaultBool = true
        return false
    }
    
    func setDefault(_ key: DefaultsKey, value: Bool) {
        didSetDefaultBool = true
    }

    func getDefault(_ key: DefaultsKey) -> String? {
        didGetDefaultString = true
        return nil
    }
    
    func setDefault(_ key: DefaultsKey, value: String) {
        didSetDefaultString = true
    }
}
