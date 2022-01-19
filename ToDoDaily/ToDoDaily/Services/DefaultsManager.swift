//
//  DefaultsManager.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation

enum DefaultsKey: String {
    case isLoggedIn
    case taskListLayoutType
    case taskListFilterType
}

typealias DefaultsStorable = RawRepresentable

protocol DefaultsManager {
    func getDefault(_ key: DefaultsKey) -> Bool
    func setDefault(_ key: DefaultsKey, value: Bool)

    func getDefault(_ key: DefaultsKey) -> String?
    func setDefault(_ key: DefaultsKey, value: String)
    
    func getDefault<T: DefaultsStorable>(_ key: DefaultsKey) -> T?
    func setDefault<T: DefaultsStorable>(_ key: DefaultsKey, value: T)
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
    
    func getDefault<T: DefaultsStorable>(_ key: DefaultsKey) -> T? {
        guard let rawValue = UserDefaults.standard.value(forKey: key.rawValue) as? T.RawValue else { return nil }
        return T(rawValue: rawValue)
    }
    
    func setDefault<T: DefaultsStorable>(_ key: DefaultsKey, value: T) {
        UserDefaults.standard.setValue(value.rawValue, forKey: key.rawValue)
    }
}

final class MockDefaultsManager: DefaultsManager {
    var didGetDefaultBool = false
    var didSetDefaultBool = false
    var didGetDefaultString = false
    var didSetDefaultString = false
    var didSetDefaultStorable = false

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
    
    func getDefault<T: DefaultsStorable>(_ key: DefaultsKey) -> T? {
        return nil
    }
    
    func setDefault<T: DefaultsStorable>(_ key: DefaultsKey, value: T) {
        didSetDefaultStorable = true
    }
}
