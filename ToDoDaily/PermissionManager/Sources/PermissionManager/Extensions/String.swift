//
//  String.swift
//  
//
//  Created by Igor Kulik on 11.01.2022.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, bundle: .module, comment: "")
    }
}
