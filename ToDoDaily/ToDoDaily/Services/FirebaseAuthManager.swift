//
//  FirebaseAuthManager.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation
import Combine
import Firebase
import FirebaseAuth
import GoogleSignIn

protocol AuthManager {
    var state: AuthState { get }
    func logIn()
    func logOut()
}

final class AuthState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var error: Error?
}

final class FirebaseAuthManager: AuthManager {
    
    // MARK: - Properties
    
    public var state: AuthState = AuthState()
    private var defaultsManager: DefaultsManager
    
    // MARK: - Lifecycle
    
    init(defaultsManager: DefaultsManager) {
        self.defaultsManager = defaultsManager
        setupValues()
    }
    
    // MARK: - Private methods
    
    private func setupValues() {
        state.isLoggedIn = self.defaultsManager.getDefault(.isLoggedIn)
    }
    
    private func processError(_ error: AuthError) {
        state.isLoggedIn = false
        state.error = error
    }
    
    private func firebaseSignIn(with credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                ConsoleLogger.shared.log(authResult)
                // TODO: - Finish sign in
            }
            
        }
    }
    
    // MARK: - Public methods
    
    public func logIn() {
        // TODO: Firebase sign-in
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            processError(.missingClientId)
            return
            
        }
        
        guard let presentingViewController = UIApplication.shared.rootViewController else {
            processError(.missingPresentingVC)
            return
        }
        
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: presentingViewController) { [weak self] user, error in
            if let error = error {
                self?.state.isLoggedIn = false
                
                if let signInError = AuthError.GoogleSignInError(rawValue: (error as NSError).code) {
                    ConsoleLogger.shared.log("sign in error occured:", signInError)
                    
                    switch signInError {
                    case .canceled:
                        break // Not an error
                    default:
                        self?.processError(.googleSignIn(signInError))
                    }
                }
                
                return
            }
            
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                self?.processError(.missingAuthProvider)
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            self?.firebaseSignIn(with: credential)
        }
        
    }
    
    public func logOut() {
        do {
          try Auth.auth().signOut()
            state.isLoggedIn = false
            defaultsManager.setDefault(.isLoggedIn, value: true)

        } catch {
            ConsoleLogger.shared.log(error)
        }

    }
}

// MARK: - Errors
extension FirebaseAuthManager {
    enum AuthError: Error {
        case missingClientId
        case missingPresentingVC
        case missingAuthProvider
        case googleSignIn(GoogleSignInError)
        
        enum GoogleSignInError: Int, Error {
            case unknown = -1
            case keychain = -2
            case hasNoAuthInKeychain = -4
            case canceled = -5
            case EMM = -6
            case noCurrentUser = -7
            case scopesAlreadyGranted = -8
        }
    }
    
}

final class MockAuthManager: AuthManager {
    var state: AuthState = AuthState()
    
    var didLogin = false
    var didLogOut = false
    
    func logIn() {
        didLogin = true
        state.isLoggedIn = true
    }
    
    func logOut() {
        didLogOut = true
        state.isLoggedIn = false
    }
    
}
