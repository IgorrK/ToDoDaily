//
//  View.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation
import SwiftUI

extension View {
    func secondaryShadowStyle(radius: CGFloat = 1.0, x: CGFloat = 0.0, y: CGFloat = 1.0) -> some View {
        self.shadow(color: Asset.Colors.secondaryShadow.color, radius: radius, x: x, y: y)
    }
}
