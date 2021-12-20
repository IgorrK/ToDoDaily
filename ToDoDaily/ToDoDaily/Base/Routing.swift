//
//  Routing.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation
import SwiftUI

typealias RouteType = Hashable

protocol Routing {
    associatedtype Route: RouteType
    associatedtype View: SwiftUI.View
        
    @ViewBuilder func view(for route: Route) -> Self.View
}
