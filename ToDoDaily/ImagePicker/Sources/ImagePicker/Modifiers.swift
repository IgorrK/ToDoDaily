//
//  Modifiers.swift
//  
//
//  Created by Igor Kulik on 28.12.2021.
//

import Foundation
import SwiftUI
import UIKit

extension ImagePicker {
    
    struct Modifier: ViewModifier {

        // MARK: - Properties
        
        @Binding var isPresented: Bool
        @Binding var pickedImage: UIImage?
        
        @State private var showsImagePicker = false
        @State private var showsPermissionDeniedAlert: Bool = false
        @State private var pickerSourceType: ImagePicker.SourceType = .photoLibrary
        
        // MARK: - ViewModifier
        
        func body(content: Content) -> some View {
            return content
                .actionSheet(isPresented: $isPresented) {
                    let commonButtonAction: EmptyCallback = {
                        ImagePicker.PermissionManager.resolvePermission(for: pickerSourceType) { status in
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
                .alert(isPresented: $showsPermissionDeniedAlert) {
                    Alert(
                        title: Text(pickerSourceType.permissionDeniedTitle),
                        message: Text(pickerSourceType.permissionDeniedMessage),
                        primaryButton: .default(Text(Localizable.Permissions.settings), action: {
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                                  UIApplication.shared.canOpenURL(settingsUrl) else {
                                      return
                                  }
                            UIApplication.shared.open(settingsUrl, completionHandler: { _ in })
                        }),
                        secondaryButton: .cancel(Text(Localizable.Permissions.notNow), action: {})
                    )
                }
                .sheet(isPresented: $showsImagePicker) {
                    ImagePicker.picker(sourceType: pickerSourceType, selectedImage: $pickedImage)
                }
        }
    }
}
