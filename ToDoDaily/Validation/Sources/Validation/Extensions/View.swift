//
//  View.swift
//  
//
//  Created by Igor Kulik on 11.12.2021.
//

import SwiftUI

public extension View {
    func validation(_ validationPublisher: Validation.Publisher) -> some View {
        self.modifier(Validation.MessageLabelModifier(validationPublisher: validationPublisher))
    }
    
    func validation(_ validationPublisher: Validation.Publisher, flag: Binding<Bool>) -> some View {
        self.modifier(Validation.ProxyModifier(validationPublisher: validationPublisher, flag: flag))
    }
}
