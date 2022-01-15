//
//  Date.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 12.01.2022.
//

import Foundation

extension Date {
    func components(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func component(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
