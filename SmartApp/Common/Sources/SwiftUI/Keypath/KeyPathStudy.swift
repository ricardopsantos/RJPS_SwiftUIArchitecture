//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

//
// https://medium.com/2-minutes-read-tip/one-interesting-advantage-you-cant-miss-in-swift-keypaths-a7eb1e068a94
//

/**
 Keypaths in iOS Swift are a powerful tool for accessing and mutating data in structs and classes.
 They allow developers to write concise, expressive code by providing a way to refer to properties and
 methods of a particular type in a type-safe way.

 A keypath is essentially a string that represents the path to a property or method of a type.
 */

//
// MARK: - KeyPathStudy
//

extension Common {
    struct KeyPathStudy {
        private init() {}
        struct Person: KeyPathConfigurationProtocol {
            var name: String
            var address: Address
        }

        struct Address: KeyPathConfigurationProtocol {
            var street: String
            var city: String
        }
    }
}

//
// MARK: - KeyPathConfigurationProtocol
//

protocol KeyPathConfigurationProtocol {}

extension KeyPathConfigurationProtocol where Self: Any {
    func with<T>(_ property: ReferenceWritableKeyPath<Self, T>, setTo value: T) -> Self {
        self[keyPath: property] = value
        return self
    }
}

extension UIView: KeyPathConfigurationProtocol {}

//
// MARK: - Sample
//

extension Common.KeyPathStudy {
    static func part1_AccessData() {
        let person = Person(
            name: "John",
            address: Address(street: "1st St", city: "NY")
        )
        _ = person[keyPath: \.address.street]
    }

    static func part2_ChangeDataV1() {
        var person = Person(
            name: "John",
            address: Address(street: "1st St", city: "NY")
        )
        person[keyPath: \.address.street] = "2nd St"
    }

    static func part3_ChangeDataV2() {
        _ = UILabel().with(\.textColor, setTo: UIColor.blue)
    }
}
