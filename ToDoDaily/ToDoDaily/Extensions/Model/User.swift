//
//  User.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 21.12.2021.
//

import Foundation
import Model
import FirebaseAuth

extension Model.User {
    init(firebaseUser: FirebaseAuth.User) {
        self.init(id: firebaseUser.uid,
                  name: firebaseUser.displayName ?? "",
                  photoURL: firebaseUser.photoURL?.absoluteString)
    }
    
    static var mockUser: Model.User {
        return Model.User(id: UUID().uuidString,
                          name: "John",
                          photoURL: nil)
    }
}
