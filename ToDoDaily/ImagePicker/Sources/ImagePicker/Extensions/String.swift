//
//  String.swift
//  
//
//  Created by Igor Kulik on 28.12.2021.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, bundle: .module, comment: "")
    }
}
