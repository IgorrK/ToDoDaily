//
//  View.swift
//  
//
//  Created by Igor Kulik on 13.12.2021.
//

import Foundation
import SwiftUI

public extension View {
    func characterLimit(_ characterLimitPublisher: CharacterLimit.Publisher, text: Binding<String>) -> some View {
        self.modifier(CharacterLimit.CharacterLimitModifier(characterLimitPublisher: characterLimitPublisher, value: text))
    }
}
