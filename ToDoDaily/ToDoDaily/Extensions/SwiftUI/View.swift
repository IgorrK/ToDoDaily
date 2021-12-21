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
    
    func alert(error: Binding<Error?>) -> some View {
        let binding = Binding(
            get: { error.wrappedValue != nil },
            set: { _ in }
        )
        
        let title: Text = {
            let string = (error.wrappedValue as? LocalizedError)?.localizedDescription
            ?? (error.wrappedValue as NSError?)?.localizedDescription
            ?? ""
            
            return Text(string)
        }()
        
        let message: Text? = {
            let failureReason = (error.wrappedValue as? LocalizedError)?.failureReason
            ?? (error.wrappedValue as NSError?)?.localizedFailureReason
            
            let recoverySuggestion = (error.wrappedValue as? LocalizedError)?.recoverySuggestion
            ?? (error.wrappedValue as NSError?)?.localizedRecoverySuggestion
            
            let message = [failureReason, recoverySuggestion].compactMap({ $0 }).joined(separator: "\n")
            return message.isEmpty ? nil : Text(message)
        }()
        
        return self
            .alert(isPresented: binding, content: {
                Alert(title: title,
                      message: message,
                      dismissButton: .default(Text(L10n.Application.ok)))
            })
    }
}
