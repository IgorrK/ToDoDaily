//
//  View.swift
//  
//
//  Created by Igor Kulik on 11.01.2022.
//

import Foundation
import SwiftUI

public extension View {
    @ViewBuilder
    func permissionDeniedAlert(permissionType: PermissionManager.PermissionType,
                               isPresented: Binding<Bool>,
                               onDismiss: (() -> Void)? = nil) -> some View {
        
        self.alert(isPresented: isPresented) {
            Alert(
                title: Text(permissionType.permissionDeniedTitle),
                message: Text(permissionType.permissionDeniedMessage),
                primaryButton: .default(Text(Localizable.Permissions.settings), action: {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                          UIApplication.shared.canOpenURL(settingsUrl) else {
                              return
                          }
                    UIApplication.shared.open(settingsUrl, completionHandler: { _ in })
                }),
                secondaryButton: .cancel(Text(Localizable.Permissions.notNow), action: {
                    onDismiss?()
                })
            )
        }
    }
}
