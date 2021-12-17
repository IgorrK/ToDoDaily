//
//  LoginView.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 16.12.2021.
//

import SwiftUI

struct LoginView: View {
    
    // MARK: - Properties
    
    @State private var primaryAnimation = false
    @State private var secondaryAnimation = false
    @State private var bottomViewAnimation = false

    // MARK: - View
    
    var body: some View {
        VStack {
            Image(Asset.Images.launchIcon)
                .resizable()
                .frame(width: secondaryAnimation ? 164.0 : 256.0, height: secondaryAnimation ? 164.0 : 256.0)
                .padding(.top, primaryAnimation ? 40.0 : 157.0)
                .padding(.bottom, 8.0)

            Text(L10n.Application.name)
                .font(.system(size: 26.0, weight: .bold))
                .opacity(secondaryAnimation ? 1.0 : 0.0)
            
            Spacer()
            
            if bottomViewAnimation {
                bottomView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 20.0)
        .background(
            Asset.Colors.launchBackground.color
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                primaryAnimation = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                secondaryAnimation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                bottomViewAnimation = true
            }

        }
        .animation(.linear, value: primaryAnimation)
        .animation(.easeInOut, value: secondaryAnimation)
        .animation(.interpolatingSpring(mass: 0.3, stiffness: 40.0, damping: 3.0, initialVelocity: 30.0), value: bottomViewAnimation)
    }
}


// MARK: - Subviews
private extension LoginView {
    
    @ViewBuilder
    var bottomView: some View {
        Color.red
            .opacity(0.1)
            .frame(height: 100.0)
            .padding(.horizontal, 32.0)
            .transition(.move(edge: .bottom))
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
