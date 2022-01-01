//
//  File.swift
//  
//
//  Created by Igor Kulik on 10.12.2021.
//

import Foundation
import SwiftUI

public extension View {
    
    @ViewBuilder
    func imagePicker(isPresented: Binding<Bool>, pickedImage: Binding<UIImage?>) -> some View {
        self.modifier(ImagePicker.Modifier(isPresented: isPresented, pickedImage: pickedImage))
    }
}
