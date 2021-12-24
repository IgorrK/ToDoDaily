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
import Model

protocol AuthManager {
    var dataContainer: AuthDataContainer { get }
    func logIn()
    func logOut()
}

final class AuthDataContainer: ObservableObject {
    
    // MARK: - Nested types
    
    enum State {
        case notAuthorized
        case authorizedNewUser(Model.User)
        case authorizedExistingUser(Model.User)
    }
    
    // MARK: - Properties
    
    @Published var state: State = .notAuthorized
    @Published var isNewUser: Bool = false
    @Published var error: Error?
    @Published var isLoading: Bool = false
}

final class FirebaseAuthManager: AuthManager {
    
    // MARK: - Properties
    
    var dataContainer: AuthDataContainer = AuthDataContainer()
    private var defaultsManager: DefaultsManager
    private var anyCancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    init(defaultsManager: DefaultsManager) {
        self.defaultsManager = defaultsManager
        setupValues()
    }
    
    // MARK: - Private methods
    
    private func setupValues() {
        //        if let currentUser = Auth.auth().currentUser {
        //            ConsoleLogger.shared.log(Model.User(firebaseUser: currentUser))
        //            dataContainer.state = .authorizedExistingUser(Model.User(firebaseUser: currentUser))
        //        }
        dataContainer.state = .notAuthorized
    }
    
    private func processError(_ error: Error) {
        dataContainer.state = .notAuthorized
        dataContainer.error = error
    }
    
    private func processLogIn(_ result: AuthDataResult) {
        dataContainer.state = .authorizedNewUser(Model.User(firebaseUser: result.user))
        defaultsManager.setDefault(.isLoggedIn, value: true)
    }
    
    private func googleSignIn() -> Future<AuthCredential, Error> {
        
        return Future() { promise in
            
            // Properties
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                promise(.failure(AuthError.missingClientId))
                return
            }
            
            guard let presentingViewController = UIApplication.shared.rootViewController else {
                promise(.failure(AuthError.missingPresentingVC))
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
                            promise(.failure(AuthError.googleSignIn(signInError)))
                        }
                    }
                    return
                }
                
                guard
                    let authentication = user?.authentication,
                    let idToken = authentication.idToken
                else {
                    promise(.failure(AuthError.missingAuthProvider))
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: authentication.accessToken)
                promise(.success(credential))
            }
        }
    }
    
    private func firebaseSignIn(with credential: AuthCredential) {
        dataContainer.isLoading = true
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            self?.dataContainer.isLoading = false
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
        var credential: AuthCredential?
        
        googleSignIn().sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished:
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
    }
    
    public func logOut() {
        do {
            try Auth.auth().signOut()
            dataContainer.state = .notAuthorized
            defaultsManager.setDefault(.isLoggedIn, value: true)
            
        } catch {
            ConsoleLogger.shared.log(error)
        }
    }
}

// MARK: - Errors
extension FirebaseAuthManager {
    enum AuthError: LocalizedError {
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
        
        // MARK: - LocalizedError
        
        var errorDescription: String? {
            return L10n.Login.AuthError.description
        }
        
        var failureReason: String? {
            return L10n.Login.AuthError.failureReason
        }
        
        var recoverySuggestion: String? {
            return L10n.Login.AuthError.recoverySuggestion
        }
    }
}

final class MockAuthManager: AuthManager {
    var dataContainer: AuthDataContainer = AuthDataContainer()
    
    var didLogin = false
    var didLogOut = false
    
    func logIn() {
        didLogin = true
        dataContainer.state = .authorizedNewUser(Model.User.mockUser)
    }
    
    func logOut() {
        didLogOut = true
        dataContainer.state = .notAuthorized
    }
    
}
