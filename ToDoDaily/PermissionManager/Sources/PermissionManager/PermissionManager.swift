//
//  PermissionManager.swift
//  
//
//  Created by Igor Kulik on 10.12.2021.
//

import Foundation
import SwiftUI

public struct PermissionManager {
    
    // MARK: - Nested types
    
    public enum PermisionStatus {
        case authorized
        case denied
        case notNow
    }
    
    public enum PermissionType {
        case photoLibrary
        case camera
        case userNotifications
    }
    
    public static func resolvePermission(for sourceType: PermissionType, completion: @escaping ((PermisionStatus) -> Void)) {
        let resolver: PermissionResolver = {
            switch sourceType {
            case .photoLibrary:
                return PhotoLibraryPermissionResolver()
            case .camera:
                return CameraPermissionResolver()
            case .userNotifications:
                return UserNotificationsPermissionResolver()
            }
        }()
        
        resolver.resolvePermission(completion)
    }
}

extension PermissionManager {
    static func resolve<ContentView: View>(_ permissionType: PermissionType,
                                           parentView: ContentView,
                                           completion: @escaping Callback<PermisionStatus>) {
        
    }
}

