//
//  PermissionManager.swift
//  
//
//  Created by Igor Kulik on 10.12.2021.
//

import Foundation

public extension ImagePicker {
    
    struct PermissionManager {
        
        // MARK: - Nested types
        
        public enum PermisionStatus {
            case authorized
            case denied
            case notNow
        }
        
        public static func resolvePermission(for sourceType: SourceType, completion: @escaping ((PermisionStatus) -> Void)) {
            let resolver: PermissionResolver = {
                switch sourceType {
                case .photoLibrary:
                    return PhotoLibraryPermissionResolver()
                case .camera:
                    return CameraPermissionResolver()
                }
            }()
            
            resolver.resolvePermission(completion)
        }
    }
}

