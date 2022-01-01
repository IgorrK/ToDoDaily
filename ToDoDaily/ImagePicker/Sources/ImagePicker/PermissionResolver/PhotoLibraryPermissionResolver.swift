//
//  PhotoLibraryPermissionResolver.swift
//  
//
//  Created by Igor Kulik on 10.12.2021.
//

import Foundation
import Photos

struct PhotoLibraryPermissionResolver: PermissionResolver {
    func resolvePermission(_ callback: @escaping Callback<ImagePicker.PermissionManager.PermisionStatus>) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            callback(.authorized)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization( { status in
                switch status {
                case .authorized, .limited:
                    callback(.authorized)
                case .denied:
                    callback(.notNow)
                default:
                    callback(.authorized)
                }
            })
        case .denied:
            callback(.denied)
        default:
            callback(.notNow)
        }
    }
}
