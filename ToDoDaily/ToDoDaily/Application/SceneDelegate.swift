//
//  SceneDelegate.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 19.12.2021.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import CircularHUD

final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    
    private var appStateContainer: AppStateContainer { Environment(\.appStateContainer).wrappedValue }
    
    private let services: Services = AppServices()
    
    private var anyCancellables = Set<AnyCancellable>()
    
    private var windowScene: UIWindowScene?
    var keyWindow: UIWindow?
    private var hudWindow: UIWindow?
    
    // MARK: - Lifecycle
    
    override init() {
        super.init()
        setBindings()
    }
    
    // MARK: - SceneDelegate
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        self.windowScene = windowScene
        self.keyWindow = setupKeyWindow(in: windowScene)
    }
    
    // MARK: - Private methods
    
    private func setupKeyWindow(in scene: UIWindowScene) -> UIWindow {
        let rootView = RootView(router: RootRouter(services: services),
                                viewModel: RootViewModel(services: services))
        
        let window = UIWindow(windowScene: scene)
        window.rootViewController = UIHostingController(rootView: rootView)
        window.makeKeyAndVisible()
        return window
    }
    
    private func setupHUDWindow(in scene: UIWindowScene) -> UIWindow {
        let hudWindow = UIWindow(windowScene: scene)
        let hudViewController = UIHostingController(rootView: CircularHUD())
        hudViewController.view.backgroundColor = .clear
        hudWindow.rootViewController = hudViewController
        return hudWindow
    }
    
    private func setBindings() {
        self.appStateContainer.hudState.$showsHUD.sink { [weak self] value in
            guard let sSelf = self else { return }
            
            if value {
                guard let windowScene = sSelf.windowScene else { return }
                let window = sSelf.setupHUDWindow(in: windowScene)
                sSelf.hudWindow = window
                window.alpha = 0.0
                window.makeKeyAndVisible()
                window.animateTransition(animations: { window.alpha = 1.0 })
            } else {
                let window = sSelf.hudWindow
                window?.animateTransition(animations: { window?.alpha = 0.0 },
                                          completion: { [weak self] _ in
                    self?.hudWindow?.isHidden = true
                    self?.hudWindow = nil
                })
            }
        }.store(in: &self.anyCancellables)
    }
}
