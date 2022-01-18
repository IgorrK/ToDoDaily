//
//  SFSymbols.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 31.12.2021.
//

import Foundation

struct SFSymbols {
    
    struct Person {
        struct Crop {
            static var circle = "person.crop.circle"
        }
    }
    
    static var xmark: String { "xmark" }
    static var gear: String { "gear" }
    static var plus: String { "plus" }
    
    struct Checkmark {
        static var `default` = "checkmark"
        
        struct Square {
            static var `default` = "checkmark.square"
            static var fill = "checkmark.square.fill"
        }
        
        struct Circle {
            static var fill = "checkmark.circle.fill"
        }
    }
    
    struct Square {
        struct And {
            static var pencil = "square.and.pencil"
        }
    }
    
    static var trash = "trash"
    
    struct Doc {
        struct On {
            static var doc = "doc.on.doc"
        }
    }
    
    struct Rectangle {
        struct Grid {
            static var oneByTwo = "rectangle.grid.1x2"
            static var twoByTwo = "rectangle.grid.2x2"
        }
    }
}
