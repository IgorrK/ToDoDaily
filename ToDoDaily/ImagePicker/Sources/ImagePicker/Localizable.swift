//
//  Localizable.swift
//  
//
//  Created by Igor Kulik on 28.12.2021.
//

import Foundation

internal struct Localizable {
    struct Sources {
        static var title: String { "sources.title".localized }
        static var camera: String { "sources.camera".localized }
        static var photoLibrary: String { "sources.photoLibrary".localized }
    }
    
    struct Permissions {
        
        struct Title {
            static var photoLibrary: String { "permissions.title.photoLibrary".localized }
            static var camera: String { "permissions.title.camera".localized }
        }
        
        static var settings: String { "permissions.settings".localized }
        static var notNow: String { "permissions.notNow".localized }
    }
}
