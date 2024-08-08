//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import XCTest
//
import Common

//
// https://www.appcoda.com/ui-testing-swiftui-xctest/
//

public extension XCUIElement {
    var attributes: String? {
        /// "Attributes: TextField, 0x12b6b6e20, {{97.7, 68.7}, {276.3, 17.0}}, placeholderValue: \'Username\', value: Username, Keyboard Focused"
        let debugDescription = debugDescription.split(by: "\n")
        return debugDescription.filter { $0.hasPrefix("Attributes:") }.first
    }

    var keyboardFocused: Bool? {
        attributes?.contains("Keyboard Focused")
    }

    func describe(_ full: Bool) -> String {
        var description = ""

        if !label.isEmpty {
            description = "{\(description)label:\(label)"
        } else {
            description = "{\(description)label:n/a"
        }
        if !identifier.isEmpty {
            description = "\(description), id:\(identifier)"
        }
        if "\(String(describing: value))" != "Optional()" {
            description = "\(description), value:\(String(describing: value))"
        }
        if !title.isEmpty {
            description = "\(description), title:\(title)"
        }
        if full {
            if elementType.rawValue == 48 {
                description = "\(description), type:text"
            } else if elementType.rawValue == 9 {
                description = "\(description), type:button"
            } else {
                description = "\(description), type:\(elementType.rawValue)"
            }
            description = "\(description), \(frame)"
        }
        description = "\(description)}"
        return description
    }
}
