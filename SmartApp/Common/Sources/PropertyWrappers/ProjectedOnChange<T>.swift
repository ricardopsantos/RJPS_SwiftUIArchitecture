//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

public extension Common_PropertyWrappers {
    @propertyWrapper
    struct ProjectedOnChange<T: Hashable> {
        public let defaultValue: T
        private let publisher = PassthroughSubject<T, Never>()
        private var value: T?
        public init(_ defaultValue: T) {
            self.defaultValue = defaultValue
        }

        /// The underlying value wrapped by the bindable state.
        /// The property that stores the wrapped value of the property. It is the value that is accessed when the property is read or written.
        public var wrappedValue: T {
            get { value ?? defaultValue }
            set {
                if newValue != wrappedValue {
                    value = newValue
                    publisher.send(newValue)
                }
            }
        }

        /// The projectedValue is an optional property that provides access to the wrapper's "projection" of the wrapped value.
        /// The projection is a separate value that can be used to perform additional operations on the wrapped value.
        /// It is accessed by appending a dollar sign ($) to the property name.
        public var projectedValue: AnyPublisher<T, Never> {
            publisher.eraseToAnyPublisher()
        }
    }
}

public extension Common_PropertyWrappers {
    @propertyWrapper
    struct ProjectedOnChangeWithCodingKey<T: Hashable> {
        public let codingKey: Any
        public var value: T?
        public let defaultValue: T

        public init(_ codingKey: Any, _ defaultValue: T) {
            self.codingKey = codingKey
            self.defaultValue = defaultValue
        }

        /// The underlying value wrapped by the bindable state.
        /// The property that stores the wrapped value of the property. It is the value that is accessed when the property is read or written.
        public var wrappedValue: T {
            get {
                guard let value else {
                    return defaultValue
                }
                return value
            }
            set {
                if newValue != wrappedValue {
                    value = newValue
                    publisher.send((newValue, codingKey))
                }
            }
        }

        /// The projectedValue is an optional property that provides access to the wrapper's "projection" of the wrapped value.
        /// The projection is a separate value that can be used to perform additional operations on the wrapped value.
        /// It is accessed by appending a dollar sign ($) to the property name.
        private let publisher = PassthroughSubject<(key: T, value: Any), Never>()
        public var projectedValue: AnyPublisher<(key: T, value: Any), Never> {
            publisher.eraseToAnyPublisher()
        }
    }
}

//
// MARK: - Sample usage
//

public extension Common_PropertyWrappers {
    // Define var
    @Common_PropertyWrappers.ProjectedOnChange(0) private static var myPropertyA: Int
    @Common_PropertyWrappers.ProjectedOnChangeWithCodingKey("key", 0) private static var myPropertyB: Int

    static func projectedOnChange_sampleUsage() {
        let cancelBag = CancelBag()
        $myPropertyA.sink { value in
            Common.LogsManager.debug("myPropertyA value changed to: \(value)")
        }.store(in: cancelBag)
        $myPropertyB.sink { some in
            Common.LogsManager.debug("myPropertyB value changed to: \(some.key) | \(some.value)")
        }.store(in: cancelBag)
        Self.myPropertyA = 1
        Self.myPropertyA = 2
        Self.myPropertyA = 2
        Self.myPropertyA = 2
        Self.myPropertyA = 2
        Self.myPropertyA = 3
        Self.myPropertyB = 1
        Self.myPropertyB = 2
        Self.myPropertyB = 2
        Self.myPropertyB = 2
        Self.myPropertyB = 2
        Self.myPropertyB = 3
    }
}
