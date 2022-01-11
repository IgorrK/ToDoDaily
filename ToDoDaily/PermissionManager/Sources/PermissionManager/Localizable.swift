//
//  Localizable.swift
//  
//
//  Created by Igor Kulik on 11.01.2022.
//

import Foundation

internal struct Localizable {
    
    struct Permissions {
        
        struct Title {
            static var photoLibrary: String { "permissions.title.photoLibrary".localized }
            static var camera: String { "permissions.title.camera".localized }
            static var userNotifications: String { "permissions.title.userNotifications".localized }
        }
        
        static var settings: String { "permissions.settings".localized }
        static var notNow: String { "permissions.notNow".localized }
    }
}
