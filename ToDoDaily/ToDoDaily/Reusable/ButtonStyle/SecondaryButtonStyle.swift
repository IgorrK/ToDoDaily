//
//  SecondaryButtonStyle.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation
import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Asset.Colors.secondaryButtonBackground.color
                .secondaryShadowStyle()
                .overlay(Asset.Colors.secondaryShadow
                            .color.opacity(configuration.isPressed ? 0.2 : 0.0))
                .cornerRadius(2.0)
            
            HStack {
                Spacer()
                
                configuration.label
                    .font(.generated(FontFamily.Roboto.medium, size: 14.0))
                    .foregroundColor(Asset.Colors.secondaryButtonForeground.color)
                
                Spacer()
            }
        }
        
        .frame(height: 40.0)
        .background(Asset.Colors.secondaryButtonBackground.color
                        .cornerRadius(2.0)
                        .secondaryShadowStyle())
    }
}
