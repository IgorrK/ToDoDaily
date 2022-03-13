//
//  FirebaseAuthCredentialsProvider.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 11.03.2022.
//

import Foundation
import Model
import Combine
import Firebase
import FirebaseAuth
import GoogleSignIn

final class FirebaseAuthCredentialsProvider: AuthCredentialsProvider {
    
    // MARK: - AuthCredentialsProvider

    var method: AuthMethod { .firebase }
    var activityPublisher = PassthroughSubject<Bool, Never>()
    
    func checkExistingUser() -> AnyPublisher<Model.User?, Never> {
        return Future<Model.User?, Never>() { promise in
            if let firebaseUser = Auth.auth().currentUser {
                promise(.success(Model.User(firebaseUser: firebaseUser)))
            } else {
                promise(.success(nil))
            }
        }.eraseToAnyPublisher()
    }

    func logIn() -> AnyPublisher<Model.User, Error> {
        return googleSignIn()
            .flatMap( { authCredential -> AnyPublisher<Model.User, Error> in
                self.firebaseSignIn(with: authCredential)
            }).eraseToAnyPublisher()
    }
    
    func logOut() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func updateCurrentUser(with user: Model.User) -> AnyPublisher<Model.User, Error> {
        return Future<Model.User, Swift.Error>() { promise in
            guard let request = Auth.auth().currentUser?.createProfileChangeRequest() else {
                promise(.failure(UpdateUserError.changeRequest))
                return
            }
            request.displayName = user.name
            let photoURL = URL(string: user.photoURL ?? "")
            request.photoURL = photoURL
            /// For some reason, it is impossible to clear user's photo, setiing `photoURL` to `nil` does nothing :/
            request.commitChanges(completion: { error in
                if let error = error {
                    promise(.failure(UpdateUserError.commit(error)))
                } else {
                    promise(.success(user))
                }
            })
        }.eraseToAnyPublisher()
    }
    
    // MARK: - Private methods
    
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
    
    private func firebaseSignIn(with credential: AuthCredential) -> AnyPublisher<Model.User, Error> {
        return Future<Model.User, Error>() { [weak self] promise in
            self?.activityPublisher.send(true)
            Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                self?.activityPublisher.send(false)
                if let error = error {
                    promise(.failure(error))
                } else if let result = authResult {
                    promise(.success(Model.User(firebaseUser: result.user)))
                } else {
                    promise(.failure(AuthError.missingAuthDataResult))
                }
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: - Errors
extension FirebaseAuthCredentialsProvider {
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
    
    enum UpdateUserError: LocalizedError {
        case changeRequest
        case commit(Swift.Error)
        
        // MARK: - LocalizedError
        
        var errorDescription: String? {
            return L10n.APIErrors.User.description
        }
        
        var failureReason: String? {
            switch self {
            case .changeRequest:
                return L10n.APIErrors.User.ChangeRequest.failureReason
            case .commit:
                return L10n.APIErrors.User.Commit.failureReason
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .changeRequest:
                return L10n.APIErrors.User.ChangeRequest.recoverySuggestion
            case .commit:
                return L10n.APIErrors.User.Commit.recoverySuggestion
            }
        }
    }
}
