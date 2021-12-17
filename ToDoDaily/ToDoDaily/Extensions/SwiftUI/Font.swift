//
//  Font.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation
import SwiftUI

extension SwiftUI.Font {
    static func generated(_ convertible: FontConvertible, size: CGFloat) -> SwiftUI.Font {
        let font = convertible.font(size: size)
        return SwiftUI.Font(font as CTFont)
    }
}
