//
//  File.swift
//  
//
//  Created by Igor Kulik on 28.12.2021.
//

import Foundation

extension ImagePicker.SourceType {
    
    var permissionDeniedTitle: String {
        switch self {
        case .photoLibrary:
            return Localizable.Permissions.Title.photoLibrary
        case .camera:
            return Localizable.Permissions.Title.camera
        }
    }
    
    var permissionDeniedMessage: String {
        switch self {
        case .photoLibrary:
            return Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryUsageDescription") as? String ?? ""
        case .camera:
            return Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") as? String ?? ""
        }
    }
}
