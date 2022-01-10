//
//  Modifiers.swift
//  
//
//  Created by Igor Kulik on 13.12.2021.
//

import Foundation
import SwiftUI
import AudioToolbox

extension CharacterLimit {
    
    struct CharacterLimitModifier: ViewModifier {
        
        
        // MARK: - Properties
        
        let characterLimitPublisher: Publisher
        @Binding var value: String
        
        @State private var latestStatus: Status = .initial {
            didSet {
                switch latestStatus {
                case .initial:
                    break
                case .success:
                    break
                case .failure(_, let limit):
                    value = String(value.prefix(limit))
                }
            }
        }
        
        private var characterCounter: some View {
            switch latestStatus {
            case .initial:
                return AnyView(EmptyView())
            case let .success(characterCount, limit):
                fallthrough
            case let .failure(characterCount, limit):
                let text = Text("\(characterCount)/\(limit)")
                    .foregroundColor(Color.secondary)
                    .font(.caption)
                return AnyView(text)
            }
        }
        
        // MARK: - ViewModifier
        
        func body(content: Content) -> some View {
            return HStack {
                content
                Spacer()
                characterCounter
            }   
            .onReceive(characterLimitPublisher) { status in
                self.latestStatus = status
                
                if case .failure(_, _) = status {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                }
            }
        }
    }
}
