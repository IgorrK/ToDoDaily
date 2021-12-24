//
//  WebImage.swift
//  
//
//  Created by Igor Kulik on 22.12.2021.
//

import SwiftUI
import Combine

public struct WebImage<Placeholder: View>: View {
    
    // MARK: - Properties
    
    @StateObject private var loader: WebImageLoader
    private let placeholder: Placeholder
    private var imageConfig: ((Image) -> Image)
    
    // MARK: - Lifecycle
    
    public init(url: String?, @ViewBuilder placeholder: () -> Placeholder, config: @escaping ((Image) -> Image)) {
        self.placeholder = placeholder()
        self.imageConfig = config
        _loader = StateObject(wrappedValue: WebImageLoader(urlString: url ?? ""))
    }
    
    // MARK: - View
    
    public var body: some View {
        content
            .onAppear(perform: loader.load)
    }

    private var content: some View {
        Group {
            if let image = loader.image {
                imageConfig(Image(uiImage: image))
            } else {
                placeholder
            }
        }
    }
}



struct WebImage_Previews: PreviewProvider {
    static var previews: some View {
        WebImage(url: "https://www.google.com/logos/doodles/2021/seasonal-holidays-2021-6753651837109324-s.png",
                 placeholder: { Image(systemName: "") },
                 config: { return $0 })
    }
}
