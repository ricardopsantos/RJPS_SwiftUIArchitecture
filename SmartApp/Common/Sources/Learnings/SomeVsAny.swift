//
//  SomeVsAny.swift
//  Common
//
//  Created by Ricardo Santos on 07/08/2024.
//

import Foundation
import SwiftUI

// https://paigeshin1991.medium.com/swift-whats-the-difference-between-some-book-vs-any-book-394333e22f77

protocol SomeVsAnyShapeProtocol {
    func draw()
}

public extension CommonLearnings {
    struct SomeVsAny {
        /**
        __TLDR__
        `any`:   is used to work with values of any type that conforms to a protocol, providing a more flexible approach where the exact type can vary.
        `some` : is used to provide an abstract type while hiding the specific implementation details, ensuring that the type conforms to a protocol but keeping it opaque.
         */
        
        struct Circle: SomeVsAnyShapeProtocol {
            func draw() {
                print("Drawing a circle")
            }
        }

        struct Square: SomeVsAnyShapeProtocol {
            func draw() {
                Common_Logs.debug("Drawing a square")
            }
        }

        func makeShape() -> some SomeVsAnyShapeProtocol {
            return Circle() // or return Square()
        }
        
        func printShape(_ shape: any SomeVsAnyShapeProtocol) {
            shape.draw()
        }
        
    }
}

