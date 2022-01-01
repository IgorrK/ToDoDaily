//
//  ImagePicker.swift
//
//
//  Created by Igor Kulik on 10.12.2021.
//

import Foundation
import SwiftUI

public struct ImagePicker {
    
    // MARK: - Nested types
    
    public enum SourceType {
        case photoLibrary
        case camera
    }

    // MARK: - Public methods
    
    @ViewBuilder
    public static func picker(sourceType: SourceType, selectedImage: Binding<UIImage?>) -> some View {
        if #available(iOS 14, *) {
            switch sourceType {
            case .photoLibrary:
                PhotoLibraryPicker(selectedImage: selectedImage)
            case .camera:
                LegacyImagePicker(sourceType: .camera, selectedImage: selectedImage)
            }
        } else {
            let sourceType: UIImagePickerController.SourceType = {
                switch sourceType {
                case .photoLibrary:
                    return .photoLibrary
                case .camera:
                    return .camera
                }
            }()
            
            LegacyImagePicker(sourceType: sourceType, selectedImage: selectedImage)
        }
    }
}
