//
//  WebImageCache.swift
//  
//
//  Created by Igor Kulik on 22.12.2021.
//

import UIKit
import Combine

public protocol ImageCache {
    subscript(_ url: String) -> UIImage? { get set }
    var insertionPublisher: AnyPublisher<ImageCacheInsertion, Never> { get }
    var currentDownloads: Set<String> { get set }
}

public typealias ImageCacheInsertion = (key: String, value: UIImage)

public struct WebImageCache: ImageCache {
    
    private let cache = NSCache<NSString, UIImage>()
    public var currentDownloads = Set<String>()
    
    public var insertionPublisher: AnyPublisher<ImageCacheInsertion, Never> {
        insertionSubject.eraseToAnyPublisher()
    }
    
    private let insertionSubject = PassthroughSubject<ImageCacheInsertion, Never>()

    
    public subscript(_ key: String) -> UIImage? {
        get { cache.object(forKey: (key as NSString)) }
        set {
            if let value = newValue {
                cache.setObject(value, forKey: (key as NSString))
                insertionSubject.send((key: key, value: value))
            } else {
                cache.removeObject(forKey: (key as NSString))
            }
        }
    }    
}
