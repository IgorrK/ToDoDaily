//
//  ProfileViewModel.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 21.12.2021.
//

import SwiftUI
import Combine
import Model
import Validation
import WebImage

final class ProfileViewModel: ObservableObject {
    
    // MARK: - Properties
    
    private var user: User
    @Published var input: Input
    
    private var anyCancellables = Set<AnyCancellable>()
    private let imageLoader: WebImageLoader?

    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        self.input = Input(user: user)
     
        if let url = user.photoURL {
            self.imageLoader = WebImageLoader(urlString: url)
        } else {
            self.imageLoader = nil
        }
        
        setBindings()
        
    }
    
    // MARK: - Private methods
    
    private func setBindings() {
        input.objectWillChange
            .sink { [weak self] (_) in
            self?.objectWillChange.send()
        }.store(in: &anyCancellables)
        
        imageLoader?.$image.sink { [weak self] image in
            self?.input.profileImage = image
        }.store(in: &anyCancellables)
    }
}

// MARK: - InteractiveViewModel
extension ProfileViewModel: InteractiveViewModel {
    enum Event: Hashable {
        case onAppear
        case setProfileImage(UIImage?)
        case done
    }
    
    func handleInput(event: Event) {
        switch event {
        case .onAppear:
            imageLoader?.load()
        case .setProfileImage(let image):
            input.setProfileImage(image)
        case .done:
            break
        }
    }
}

// MARK: - Input
extension ProfileViewModel {
    final class Input: ObservableObject {
        
        // MARK: - Properties
        
        @Published var name: String
        @Published var profileImage: UIImage?
        
        // MARK: - Lifecycle
        
        init(user: User) {
            self.name = user.name
        }
        
        // MARK: - Private methods
        
        fileprivate func setProfileImage(_ image: UIImage?) {
            profileImage = image
        }
        
        // MARK: - Validation
                
        lazy var nameValidation: Validation.Publisher = {
            $name.nonEmptyValidator("Name cannot be empty")
        }()
    }
}
