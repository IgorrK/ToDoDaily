//
//  PhotoLibraryPicker.swift
//  
//
//  Created by Igor Kulik on 10.12.2021.
//

import Foundation
import PhotosUI
import SwiftUI

@available(iOS 14, *)
struct PhotoLibraryPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController

    // MARK: - Properties
    
    let selectionLimit: Int = 1
    @Binding var selectedImage: UIImage?

    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = selectionLimit

        let controller = PHPickerViewController(configuration: configuration)

        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}

// MARK: - Coordinator

@available(iOS 14, *)
extension PhotoLibraryPicker {
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, completion: { result in
            switch result {
            case .success(let images):
                    selectedImage = images.first
            case .failure(let error):
                // error handling is not really needed for now, so the error is just printed out
                print("`PhotoLibraryPicker` error:\n", error)
            }
        })
    }

    final class Coordinator: PHPickerViewControllerDelegate {

        // MARK: - Properties
    
        var completion: ResultCallback<[UIImage]>?
        
        private let parent: PhotoLibraryPicker

        // MARK: - Lifecycle
        
        init(_ parent: PhotoLibraryPicker, completion: ResultCallback<[UIImage]>?) {
            self.parent = parent
            self.completion = completion
        }
        
        // MARK: - PHPickerViewControllerDelegate

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

            picker.dismiss(animated: true)
            
            var images = [UIImage]()
            var error: Error?
            
            let dispatchGroup = DispatchGroup()
            for result in results {
                dispatchGroup.enter()
                let itemProvider = result.itemProvider
                guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
                    error = NSError()
                    dispatchGroup.leave()
                    continue
                }
                itemProvider.loadObject(ofClass: UIImage.self) { (imageOrNil, errorOrNil) in
                    if let loadError = errorOrNil {
                        error = loadError
                    }
                    if let image = imageOrNil as? UIImage {
                        images.append(image)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) { [weak self] in
                guard let sSelf = self else { return }
                
                if let error = error {
                    sSelf.completion?(.failure(error))
                    return
                }
                                
                if images.count <= sSelf.parent.selectionLimit {
                    sSelf.completion?(.success(images))
                } else {
                    sSelf.completion?(.success(Array(images.prefix(upTo: sSelf.parent.selectionLimit))))
                }
            }
        }
    }

}
