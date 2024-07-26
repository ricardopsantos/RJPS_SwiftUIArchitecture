//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//
import Foundation
import Combine

public protocol LoggableStateProtocol {}

public extension LoggableStateProtocol {
    var debugState: String {
        var acc = "# \(type(of: self))\n"
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let propertyName = child.label else {
                continue
            }
            let value = child.value
            let type = "\(type(of: value))"
            let propertyA = "\(propertyName.trim)"
            let propertyB = "\(propertyA): \(type)"
            let valueId = ".value("
            if type.hasPrefix("Published"), var unwrapped = "\(value)".split(by: valueId).last {
                unwrapped = unwrapped.dropLastIf("))")
                acc += " . \(propertyB) = \(unwrapped)\n"
            } else if type.hasPrefix("AppStorage") {
                if let unwrapped = UserDefaults.standard.value(forKey: "\(propertyA)".dropFirstIf("_")) {
                    acc += " . \(propertyB) = \(unwrapped)\n"
                } else {
                    acc += " . \(propertyB) = \(value)\n"
                }
            } else {
                acc += " . \(propertyB) = \(value)\n"
            }
        }
        return acc
    }
}

public extension Common {
    struct Loggable: LoggableStateProtocol {
        var street: String
        var city: String
    }
}

public extension Common.Loggable {
    static func test() {
        var loggable = Common.Loggable(street: "123 Main St", city: "Anytown")
        loggable.street = "456 Elm St" // triggers log message: "street changed from 123 Main St to 456 Elm St"
        loggable.city = "Newtown" // triggers log message: "city changed from Anytown to Newtown"
    }
}
