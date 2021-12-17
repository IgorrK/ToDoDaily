//
//  GoogleSignInButton.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation
import UIKit
import SwiftUI
import GoogleSignIn

struct GoogleSignInButton: UIViewRepresentable {

    var onAction: EmptyCallback
    
    func makeUIView(context: Context) -> GIDSignInButton {
        let button = GIDSignInButton()
        button.style = .wide
        button.colorScheme = Style.colorScheme
        button.addTarget(context.coordinator, action: #selector(context.coordinator.signInAction(_:)), for: .touchUpInside)
        return button

    }
    
    func updateUIView(_ uiView: GIDSignInButton, context: Context) {}
}

// MARK: - Coordinator
extension GoogleSignInButton {
    func makeCoordinator() -> Coordinator {
        Coordinator(self, actionCallback: onAction)
    }

    final class Coordinator: NSObject {
        
        var onAction: EmptyCallback
        var parent: GoogleSignInButton

        init(_ parent: GoogleSignInButton, actionCallback: @escaping EmptyCallback) {
            self.parent = parent
            self.onAction = actionCallback
        }
        
        @objc
        fileprivate func signInAction(_ sender: GIDSignInButton) {
            onAction()
        }
    }
}

private struct Style {
    private static var systemColorScheme: UIUserInterfaceStyle { UITraitCollection.current.userInterfaceStyle }

    static var colorScheme: GIDSignInButtonColorScheme {
        switch systemColorScheme {
        case .unspecified:
            return .light
        case .light:
            return .light
        case .dark:
            return .dark
        @unknown default:
            return .light
        }
    }
}
