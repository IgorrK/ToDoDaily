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
    private var anyCancellables = Set<AnyCancellable>()
    private var imageLoader: WebImageLoader?
    private var user: User? { dataContainer.user }
    private var dataContainer: UserDataContainer { Environment(\.userDataContainer).wrappedValue}

    @Published var input: Input
    
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var currentProfileImage: UIImage?
    
    var viewDismissalPublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismiss = false {
        didSet {
            viewDismissalPublisher.send(shouldDismiss)
        }
    }

    // MARK: - Lifecycle
    
    init(services: Services) {
        self.services = services
        self.input = Input()
        setBindings()
    }
    
    // MARK: - Private methods
    
    private func setBindings() {
        input.objectWillChange
            .sink { [weak self] (_) in
            self?.objectWillChange.send()
        }.store(in: &anyCancellables)
    }
    
    private func updateProfileIfNeeded() {
        guard let user = user else { return }
        
        if input.name == user.name && input.profileImage == nil { // i.e. nothing was actually changed
            services.authManager.dataContainer.handle(event: .updatedUserProfile(user))
            shouldDismiss = true
            return
        }
        
        var updatedUser = user
        updatedUser.name = input.name
        
        isLoading = true
        uploadImageIfNeeded()
            .flatMap { [unowned self] imageURL -> AnyPublisher<Model.User, Error> in
                updatedUser.photoURL = imageURL
                return self.services.authManager.updateCurrentUser(with: updatedUser)
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
                self?.services.authManager.dataContainer.handle(event: .updatedUserProfile(updatedUser))
                self?.input.profileImage = nil
                self?.shouldDismiss = true
            })
            .store(in: &anyCancellables)
    }
    
    private func uploadImageIfNeeded() -> AnyPublisher<String?, Error> {
        if let pickedImage = input.profileImage {
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
        case done
    }
    
    func handleInput(event: Event) {
        switch event {
        case .onAppear:
            if let url = user?.photoURL {
                imageLoader = WebImageLoader(urlString: url)
                imageLoader?.$image.sink { [weak self] image in
                    self?.currentProfileImage = image
                }.store(in: &anyCancellables)
                imageLoader?.load()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                if let user = self?.user {
                    self?.input.setUser(user)
                }
            })
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
        
        // MARK: - Lifecycle
        
        init() {}
        
        init(user: User) {
            self.name = user.name
        }
        
        // MARK: - Private methods
        
        fileprivate func setUser(_ user: User) {
            name = user.name
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
