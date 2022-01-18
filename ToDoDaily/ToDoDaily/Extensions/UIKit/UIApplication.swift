//
//  UIApplication.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 18.12.2021.
//

import UIKit

extension UIApplication {
    var currentKeyWindow: UIWindow? {
        self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
    }
    
    var rootViewController: UIViewController? {
        currentKeyWindow?.rootViewController
    }
}
