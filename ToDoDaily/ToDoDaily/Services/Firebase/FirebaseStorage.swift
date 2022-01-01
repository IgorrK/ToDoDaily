//
//  FirebaseStorage.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 28.12.2021.
//

import SwiftUI
import FirebaseStorage
import Combine

final class StorageManager: ObservableObject {
    
    // MARK: - Properties
    
    private static let storage = Storage.storage()
    
    // MARK: - Public methods
    
    static func upload(image: UIImage) -> AnyPublisher<String, Error> {
        return performUpload(image: image)
            .flatMap({ storageRef -> AnyPublisher<String, Error> in
                Self.getURL(from: storageRef)
            }).eraseToAnyPublisher()
    }
    
    // MARK: - Private methods
    
    private static func performUpload(image: UIImage) -> AnyPublisher<StorageReference, Error> {
        return Future<StorageReference, Error>() { promise in
            guard let data = image.jpegData(compressionQuality: Constants.compressionQuality) else {
                promise(.failure(ImageUploadError.compression))
                return
            }
            
            let storageRef = Self.storage.reference().child("\(Constants.storagePath)\(UUID().uuidString)")
            let metadata = StorageMetadata()
            metadata.contentType = Constants.contentType
            
            storageRef.putData(data, metadata: metadata) { (metadata, error) in
                if let error = error {
                    
                    promise(.failure(ImageUploadError.upload(error)))
                } else {
                    promise(.success(storageRef))
                }
                
            }
        }.eraseToAnyPublisher()
    }
    
    private static func getURL(from storageReference: StorageReference) -> AnyPublisher<String, Error> {
        return Future<String, Error>() { promise in
            Task {
                do {
                    let url = try await storageReference.downloadURL()
                    promise(.success(url.absoluteString))
                } catch {
                    promise(.failure(ImageUploadError.urlReference(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: - Nested types
extension StorageManager {
    
    private struct Constants {
        static var compressionQuality: CGFloat { 0.5 }
        static var storagePath: String { "images/" }
        static var contentType: String { "image/jpg" }
    }
    
    enum ImageUploadError: LocalizedError {
        case compression
        case upload(Error)
        case urlReference(Error)
        
        // MARK: - LocalizedError
        
        var errorDescription: String? {
            return L10n.Storage.ImageUploadError.description
        }
        
        var failureReason: String? {
            switch self {
            case .compression:
                return L10n.Storage.ImageUploadError.Compression.failureReason
            case .upload:
                return L10n.Storage.ImageUploadError.Upload.failureReason
            case .urlReference:
                return L10n.Storage.ImageUploadError.UrlReference.failureReason
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .compression:
                return L10n.Storage.ImageUploadError.Compression.recoverySuggestion
            case .upload:
                return L10n.Storage.ImageUploadError.Upload.recoverySuggestion
            case .urlReference:
                return L10n.Storage.ImageUploadError.UrlReference.recoverySuggestion
            }
        }
    }
}
