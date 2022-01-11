//
//  Modifiers.swift
//  
//
//  Created by Igor Kulik on 28.12.2021.
//

import Foundation
import SwiftUI
import UIKit
import PermissionManager

extension ImagePicker {
    
    struct Modifier: ViewModifier {

        // MARK: - Properties
        
        @Binding var isPresented: Bool
        @Binding var pickedImage: UIImage?
        
        @State private var showsImagePicker = false
        @State private var showsPermissionDeniedAlert: Bool = false
        @State private var pickerSourceType: ImagePicker.SourceType = .photoLibrary
        
        private var permissionType: PermissionManager.PermissionType {
            switch pickerSourceType {
            case .camera:
                return .camera
            case .photoLibrary:
                return .photoLibrary
            }
        }
        
        // MARK: - ViewModifier
        
        func body(content: Content) -> some View {
            return content
                .actionSheet(isPresented: $isPresented) {
                    let commonButtonAction: EmptyCallback = {
                        PermissionManager.resolvePermission(for: permissionType) { status in
                            switch status {
                            case .authorized:
                                showsImagePicker.toggle()
                            case .denied:
                                showsPermissionDeniedAlert.toggle()
                            case .notNow:
                                break
                            }
                        }
                    }
                    
                    return ActionSheet(title: Text(Localizable.Sources.title),
                                       buttons: [
                                        .default(Text(Localizable.Sources.photoLibrary)) {
                                            pickerSourceType = .photoLibrary
                                            commonButtonAction()
                                        },
                                        .default(Text(Localizable.Sources.camera)) {
                                            pickerSourceType = .camera
                                            commonButtonAction()
                                        },
                                        .cancel()
                                       ])
                }
                .permissionDeniedAlert(permissionType: permissionType, isPresented: $showsPermissionDeniedAlert)
                .sheet(isPresented: $showsImagePicker) {
                    ImagePicker.picker(sourceType: pickerSourceType, selectedImage: $pickedImage)
                }
        }
    }
}
