//
//  RoutableView.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation
import SwiftUI

protocol RoutableView: View {
    associatedtype Router: Routing
    
    var router: Router { get }
}
