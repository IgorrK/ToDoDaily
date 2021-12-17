//
//  Typealiases.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 17.12.2021.
//

import Foundation

typealias EmptyCallback = () -> Void
typealias Callback<T> = (T) -> Void
typealias ResultCallback<T> = Callback<Result<T, Error>>
