//
//  Published.swift
//  
//
//  Created by Igor Kulik on 13.12.2021.
//

import Foundation
import SwiftUI

public extension Published.Publisher where Value == String {
    func characterLimit(_ limit: Int) -> CharacterLimit.Publisher {
        return CharacterLimit.Publishers.characterLimit(for: self, characterLimit: limit)
    }
}
