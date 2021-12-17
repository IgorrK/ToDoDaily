//
//  UIScreen.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import UIKit

extension UIScreen {
    struct Geometry {
        static var size: CGSize { UIScreen.main.bounds.size }
        static var width: CGFloat { size.width }
        static var height: CGFloat { size.height }
    }
}
