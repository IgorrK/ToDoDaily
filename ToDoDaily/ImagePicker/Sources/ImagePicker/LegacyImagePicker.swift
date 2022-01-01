//
//  LegacyImagePicker.swift
//  
//
//  Created by Igor Kulik on 10.12.2021.
//

import Foundation
import SwiftUI

struct LegacyImagePicker: UIViewControllerRepresentable {
    
    // MARK: - Properties
    
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage?
        
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<LegacyImagePicker>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<LegacyImagePicker>) {}
}

// MARK: - Coordinator

extension LegacyImagePicker {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        // MARK: - Properties
        
        var parent: LegacyImagePicker
        
        // MARK: - Lifecycle
        
        init(_ parent: LegacyImagePicker) {
            self.parent = parent
        }
        
        // MARK: - UIImagePickerControllerDelegate
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
