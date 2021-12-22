//
//  Modifiers.swift
//  
//
//  Created by Igor Kulik on 11.12.2021.
//

import SwiftUI

extension Validation {
    
    struct MessageLabelModifier: ViewModifier {
        
        // MARK: - Properties
        
        @State var latestValidation: Status = .success
        let validationPublisher: Publisher
        
        var validationMessage: some View {
            switch latestValidation {
            case .success:
                return AnyView(EmptyView())
            case .failure(let message):
                let text = Text(message)
                    .foregroundColor(Color.red)
                    .font(.caption)
                return AnyView(text)
            }
        }
        
        // MARK: - ViewModifier
        
        func body(content: Content) -> some View {
            return VStack(alignment: .leading) {
                content
                validationMessage
            }
            .onReceive(validationPublisher) { validation in
                self.latestValidation = validation
            }
        }
    }
    
    struct ProxyModifier: ViewModifier {
        
        // MARK: - Properties
        
        let validationPublisher: Publisher
        @Binding var flag: Bool
        
        @State var latestValidation: Status = .success {
            didSet {
                switch latestValidation {
                case .success:
                    flag = true
                case .failure:
                    flag = false
                }
            }
        }
        
        // MARK: - ViewModifier
        
        func body(content: Content) -> some View {
            return content
                .onReceive(validationPublisher) { validation in
                    self.latestValidation = validation
                }
        }
    }
}
