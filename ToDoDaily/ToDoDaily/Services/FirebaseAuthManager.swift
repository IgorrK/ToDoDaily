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
    @Published var isLoading: Bool = false
}

final class FirebaseAuthManager: AuthManager {
    
    // MARK: - Properties
    
    var state: AuthState = AuthState()
    private var defaultsManager: DefaultsManager
    private var anyCancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle
    
    init(defaultsManager: DefaultsManager) {
        self.defaultsManager = defaultsManager
        setupValues()
    }
    
    // MARK: - Private methods
    
    private func setupValues() {
        state.isLoggedIn = self.defaultsManager.getDefault(.isLoggedIn)
    }
    
    private func processError(_ error: Error) {
        state.isLoggedIn = false
        state.error = error
    }
    
    private func processLogIn(_ result: AuthDataResult) {
        state.isLoggedIn = true
        defaultsManager.setDefault(.isLoggedIn, value: state.isLoggedIn)
    }
    
    private func firebaseSignIn(with credential: AuthCredential) {
        state.isLoading = true
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            self?.state.isLoading = false
            if let error = error {
                self?.processError(error)
            } else if let result = authResult {
                self?.processLogIn(result)
            } else {
                self?.processError(AuthError.missingAuthDataResult)
            }
        }
    }
    
    // MARK: - Public methods
    
    public func logIn() {
        
        // Combine publisher
        var credential: AuthCredential?
        let googleSignInSubject = PassthroughSubject<AuthCredential, Error>()

        googleSignInSubject
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ConsoleLogger.shared.log("finished")
                    if let credential = credential {
                        self?.firebaseSignIn(with: credential)
                    } else {
                        self?.processError(AuthError.missingAuthCredential)
                    }
                case .failure(let error):
                    self?.processError(error)
                }
        }, receiveValue: { value in
            credential = value
        }).store(in: &anyCancellables)

        // Properties
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            googleSignInSubject.send(completion: .failure(AuthError.missingClientId))
            return
        }
        
        guard let presentingViewController = UIApplication.shared.rootViewController else {
            googleSignInSubject.send(completion: .failure(AuthError.missingPresentingVC))
            return
        }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        // Start the sign in flow
        GIDSignIn.sharedInstance.signIn(with: config, presenting: presentingViewController) { user, error in
            if let error = error {
                if let signInError = AuthError.GoogleSignInError(rawValue: (error as NSError).code) {
                    switch signInError {
                    case .canceled:
                        break // Not an error
                    default:
                        googleSignInSubject.send(completion: .failure(AuthError.googleSignIn(signInError)))
                    }
                }
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                googleSignInSubject.send(completion: .failure(AuthError.missingAuthProvider))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            googleSignInSubject.send(credential)
            googleSignInSubject.send(completion: .finished)
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
        case missingAuthCredential
        case missingAuthDataResult
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
