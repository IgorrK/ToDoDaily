//
//  UIView.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 20.12.2021.
//

import Foundation
import UIKit

extension UIView {
    func animateTransition(duration: TimeInterval = 0.25,
                           options: UIView.AnimationOptions = .transitionCrossDissolve,
                           animations: @escaping EmptyCallback,
                           completion: Callback<Bool>? = nil) {
        UIView.transition(with: self, duration: duration, options: options, animations: animations, completion: completion)
    }
    
    @discardableResult
    func prepareForAutoLayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}
