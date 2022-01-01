//
//  PermissionResolver.swift
//  
//
//  Created by Igor Kulik on 10.12.2021.
//

import Foundation

protocol PermissionResolver {
    func resolvePermission(_ callback: @escaping Callback<ImagePicker.PermissionManager.PermisionStatus>)
}
