//
//  LoginView.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 16.12.2021.
//

import SwiftUI

struct LoginView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: LoginViewModel
    
    @State private var primaryAnimation = false
    @State private var secondaryAnimation = false
    @State private var bottomViewAnimation = false
    
    @EnvironmentObject var appStateContainer: AppStateContainer
    
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
            Asset.Colors.primaryBackground.color
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            viewModel.bind(to: appStateContainer)
            performAnimations()
        }
        .animation(.linear, value: primaryAnimation)
        .animation(.easeInOut, value: secondaryAnimation)
        .animation(.interpolatingSpring(mass: 0.3, stiffness: 40.0, damping: 10.0, initialVelocity: 30.0), value: bottomViewAnimation)
    }
}

// MARK: - Private methods
private extension LoginView {
    func performAnimations() {
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
}

// MARK: - Subviews
private extension LoginView {
    
    @ViewBuilder
    var bottomView: some View {
        VStack(spacing: 16.0) {
            GoogleSignInButton {
                viewModel.handleInput(event: .onGoogleSignIn)
            }
            .frame(height: 48.0)
            
            HStack(alignment: .center) {
                lineSeparatorView
                
                Text(L10n.Login.or)
                    .font(.generated(FontFamily.Roboto.medium, size: 12.0))
                    .foregroundColor(.secondary.opacity(0.7))
                    .secondaryShadowStyle()
                lineSeparatorView
            }
            .padding(.horizontal, 16.0)
            
            HStack {
                Button(L10n.Login.goOffline) {
                    viewModel.handleInput(event: .onGoOffline)
                }
                .buttonStyle(SecondaryButtonStyle())
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 4.0)
        }
        .frame(width: 260.0, height: 100.0)
        .padding(.horizontal, 32.0)
        .padding(.bottom, 32.0)
        .transition(.move(edge: .bottom))
        // TODO: show alert on error
    }
    
    @ViewBuilder
    var lineSeparatorView: some View {
        LinePath()
            .stroke(style: StrokeStyle(lineWidth: 1.0, lineCap: .round))
            .foregroundColor(.secondary.opacity(0.7))
            .frame(height: 1.0)
            .secondaryShadowStyle()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel(services: MockServices()))
    }
}

private struct LinePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0.0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.size.width, y: rect.midY))
        path.closeSubpath()
        
        return path
    }
}
