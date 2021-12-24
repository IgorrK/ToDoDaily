//
//  ImageLoader.swift
//  
//
//  Created by Igor Kulik on 22.12.2021.
//

import SwiftUI
import Combine
import Foundation

public final class WebImageLoader: ObservableObject {
    
    // MARK: - Properties
    
    @Published public var image: UIImage?
    private let urlString: String
    private var url: URL? { URL(string: urlString) }
    private var anyCancellables = Set<AnyCancellable>()
    private var cache: ImageCache
    private(set) var isLoading = false 
    private static let imageProcessingQueue = DispatchQueue(label: "imageProcessing")

    // MARK: - Lifecycle
    
    public init(urlString: String, cache: ImageCache = Environment(\.imageCache).wrappedValue) {
        self.urlString = urlString
        self.cache = cache
    }
    
    deinit {
        cancel()
    }
    
    // MARK: - Public methods
    
    public func load() {
        
        guard let url = URL(string: urlString) else { return }
        
        /// If current `ImageLoader` instance is already loading an image,
        /// do nothing and wait for the existing download to finish.
        guard !isLoading else { return }
        
        /// Check if the image is already cached.
        if let image = cache[urlString] {
            self.image = image
            return
        }
        
        /// Start download task only if the image with specified `url`
        /// **is not** already being downloaded somewhere else.
        if !cache.currentDownloads.contains(urlString) {
            URLSession.shared.dataTaskPublisher(for: url)
                .subscribe(on: Self.imageProcessingQueue)
                .map { UIImage(data: $0.data) }
                .replaceError(with: nil)
                .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
                              receiveCancel: { [weak self] in self?.onFinish() })
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] _ in self?.onFinish() },
                      receiveValue: { [weak self] in self?.cache($0) })
                .store(in: &anyCancellables)
        }
        
        /// Subscribe to cache updates in order to get the image.
        cache.insertionPublisher
            .sink { [weak self] (key, value) in
                guard key == self?.urlString else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.image = value
                }
            }
            .store(in: &anyCancellables)
    }
    
    public func cancel() {
        anyCancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Private methods
    
    private func onStart() {
        cache.currentDownloads.insert(urlString)
        isLoading = true
    }
    
    private func onFinish() {
        isLoading = false
    }
    
    private func cache(_ image: UIImage?) {
        cache.currentDownloads.remove(urlString)
        cache[urlString] = image
    }
}
