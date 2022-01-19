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
    
    func circularHUD(isShowing: Published<Bool>.Publisher) -> some View {
        self.modifier(CircularHUDModifier(isShowing: isShowing))
    }
}

// MARK: - Placeholder
extension View {
    func placeholderStyle<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            return self.modifier(Placeholder(placeholder: placeholder(), show: shouldShow, alignment: alignment))
        }
}

fileprivate struct Placeholder<P: View>: ViewModifier {
    var placeholder: P
    var show: Bool
    var alignment: Alignment
    
    func body(content: Content) -> some View {
        ZStack(alignment: alignment) {
            if show { placeholder }
            content
        }
    }
}

// MARK: - Scaled font

extension View {
    func scaledSystemFont(size: CGFloat,
                          weight: SwiftUI.Font.Weight = .regular,
                          design: SwiftUI.Font.Design = .default) -> some View {
        return self.modifier(ScaledSystemFont(size: size, weight: weight, design: design))
    }
}

fileprivate struct ScaledSystemFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    var size: CGFloat
    var weight: SwiftUI.Font.Weight
    var design: SwiftUI.Font.Design
    
    func body(content: Content) -> some View {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return content.font(.system(size: scaledSize, weight: weight, design: design))
    }
}
