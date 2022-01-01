//
//  CameraPermissionResolver.swift
//  
//
//  Created by Igor Kulik on 10.12.2021.
//

import Foundation
import AVFoundation

struct CameraPermissionResolver: PermissionResolver {
    
    func resolvePermission(_ callback: @escaping Callback<ImagePicker.PermissionManager.PermisionStatus>) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            callback(.authorized)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { isAuthorized in
                callback(isAuthorized ? .authorized : .notNow)
            })
        case .denied:
            callback(.denied)
        default:
            callback(.notNow)
        }
    }
}
