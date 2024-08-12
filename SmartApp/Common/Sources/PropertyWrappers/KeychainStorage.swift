//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

// https://medium.com/bforbank-tech/swiftui-dynamic-property-with-keychainstorage-example-a0e219bc313c

public extension Common_PropertyWrappers {
    @propertyWrapper
    struct KeychainStorageV2: DynamicProperty {
        @State private var value: String?
        private let key: String
        private let container = Keychain(service: Bundle.main.bundleIdentifier ?? "\(Common.self)_\(Self.self)")
        init(key: String) {
            self.key = key
            _value = State(initialValue: container[key])
        }

        public var wrappedValue: String? {
            get { value }
            nonmutating set {
                if let newValue {
                    container[key] = newValue
                } else {
                    container[key] = nil
                }
                value = newValue
            }
        }

        public var projectedValue: Binding<String?> {
            Binding {
                wrappedValue
            } set: { newValue in
                wrappedValue = newValue
            }
        }
    }
}

public extension Common_PropertyWrappers {
    /// DynamicProperty protocol, which enables automatic view updates when the wrapped value changes
    @propertyWrapper
    struct KeychainStorageV1: DynamicProperty {
        @ObservedObject var viewUpdateTrigger = ViewUpdateTrigger()
        public let key: String
        public let defaultValue: String
        public var onChange: () -> Void
        public let publisher = PassthroughSubject<String, Never>()
        private let container: Keychain
        public init(value: String, key: String, onChange: @escaping () -> Void = {}) {
            self.key = key
            self.defaultValue = value
            self.container = Keychain(service: Bundle.main.bundleIdentifier ?? "\(Common.self)_\(Self.self)")
            self.onChange = onChange
        }

        private let synchronizedQueue = DispatchQueue(
            label: "\(Common.self)_\(Self.self)",
            attributes: .concurrent
        )

        /// The underlying value wrapped by the bindable state.
        /// The property that stores the wrapped value of the property. It is the value that is accessed when the property is read or written.
        public var wrappedValue: String {
            get { getWrappedValue() }
            set { setWrappedValue(newValue) }
        }

        /// The projectedValue is an optional property that provides access to the wrapper's "projection" of the wrapped value.
        /// The projection is a separate value that can be used to perform additional operations on the wrapped value.
        /// It is accessed by appending a dollar sign ($) to the property name.
        public var projectedValue: Binding<String> {
            Binding(
                get: { wrappedValue },
                set: { setWrappedValue($0) }
            )
        }

        private func getWrappedValue() -> String {
            synchronizedQueue.sync {
                if let value = container[key] {
                    return value
                }
                return defaultValue
            }
        }

        private func setWrappedValue(_ newValue: String) {
            func equals(_ object1: Codable, _ object2: Codable) -> Bool {
                let encoder = JSONEncoder()
                let data1 = try? encoder.encode(object1)
                let data2 = try? encoder.encode(object2)
                return data1 == data2
            }

            let areEqual = equals(newValue, getWrappedValue())

            guard !areEqual else {
                return
            }

            // Check whether we're dealing with an optional and remove the object if the new value is nil.
            synchronizedQueue.sync(flags: .barrier) {
                if let optional = newValue as? AnyOptional, optional.isNil {
                    container[key] = nil
                } else {
                    container[key] = newValue
                }
            }
            viewUpdateTrigger.notify()
            onChange()
            publisher.send(newValue)
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
fileprivate extension Common_Preview {
    struct KeyChainTestViewView: View {
        @AppStorage("myKey1")
        public var text1: String = "default value"

        @Common_PropertyWrappers.KeychainStorageV1(value: "default value", key: "myKey2")
        var text2: String

        var body: some View {
            VStack {
                TextField("Enter text", text: $text1)
                Text(text1)
                Text($text1.wrappedValue)
                Divider()
                TextField("Enter text", text: $text2)
                Text(text2)
                Text($text2.wrappedValue)
            }
        }
    }
}

#Preview {
    Common_Preview.KeyChainTestViewView()
}
#endif
