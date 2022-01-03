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
    
    private let services: Services
    private var user: User
    private var anyCancellables = Set<AnyCancellable>()
    private let imageLoader: WebImageLoader?
    
    @Published var input: Input
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    var viewDismissalPublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismiss = false {
        didSet {
            viewDismissalPublisher.send(shouldDismiss)
        }
    }

    // MARK: - Lifecycle
    
    init(user: User, services: Services) {
        self.user = user
        self.services = services
        self.input = Input()
     
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
    
    private func updateProfileIfNeeded() {
        if input.name == user.name && !input.profileImageWasChanged { // i.e. nothing was actually changed
            services.authManager.dataContainer.handle(event: .updatedUserProfile(user))
            shouldDismiss = true
            return
        }
        
        var updatedUser = user
        updatedUser.name = input.name
        
        isLoading = true
        uploadImageIfNeeded()
            .flatMap { imageURL -> AnyPublisher<Model.User, Error> in
                updatedUser.photoURL = imageURL
                return FirebaseAPI.updateCurrentUser(with: updatedUser)
            }
            .sink(receiveCompletion: { [weak self] result in
                self?.isLoading = false
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                }
            }, receiveValue: { [weak self] user in
                self?.user = user
                self?.services.authManager.dataContainer.handle(event: .updatedUserProfile(updatedUser))
                self?.shouldDismiss = true
            })
            .store(in: &anyCancellables)
    }
    
    private func uploadImageIfNeeded() -> AnyPublisher<String?, Error> {
        if let pickedImage = input.profileImage,
           input.profileImageWasChanged {
            return StorageManager.upload(image: pickedImage)
                .map { $0 as String? }
                .eraseToAnyPublisher()
        } else {
            return Just<String?>(nil)
                .setFailureType(to: Error.self)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [unowned self] in
                self.input.setUser(self.user)
            })
        case .setProfileImage(let image):
            input.setProfileImage(image)
        case .done:
            updateProfileIfNeeded()
        }
    }
}

// MARK: - Input
extension ProfileViewModel {
    final class Input: ObservableObject {
        
        // MARK: - Properties
        
        @Published var name: String = ""
        @Published var profileImage: UIImage?
        @Published var isDoneEnabled: Bool = false
        
        private var anyCancellables = Set<AnyCancellable>()
        fileprivate var profileImageWasChanged: Bool = false
        
        // MARK: - Lifecycle
        
        init() {}
        
        init(user: User) {
            self.name = user.name
        }
        
        // MARK: - Private methods
        
        fileprivate func setUser(_ user: User) {
            name = user.name
        }
        
        fileprivate func setProfileImage(_ image: UIImage?) {
            profileImageWasChanged = true
            profileImage = image
        }
        
        // MARK: - Validation
                
        lazy var nameValidation: Validation.Publisher = {
            $name.nonEmptyValidator(L10n.Profile.Name.validation)
        }()
        
        lazy var doneButtonValidation: Validation.Publisher = {
            nameValidation.eraseToAnyPublisher()
        }()
    }
}
