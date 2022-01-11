//
//  File.swift
//  
//
//  Created by Igor Kulik on 11.01.2022.
//

import Foundation

extension PermissionManager.PermissionType {
    
    var permissionDeniedTitle: String {
        switch self {
        case .photoLibrary:
            return Localizable.Permissions.Title.photoLibrary
        case .camera:
            return Localizable.Permissions.Title.camera
        case .userNotifications:
            return Localizable.Permissions.Title.userNotifications
        }
    }
    
    var permissionDeniedMessage: String {
        switch self {
        case .photoLibrary:
            return Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryUsageDescription") as? String ?? ""
        case .camera:
            return Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") as? String ?? ""
        case .userNotifications:
            return ""
        }
    }
}
