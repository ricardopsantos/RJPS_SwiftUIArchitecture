//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

public protocol AnyOptional {
    /// Returns `true` if `nil`, otherwise `false`.
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
}

public class ViewUpdateTrigger: ObservableObject {
    public init() {}
    public func notify() {
        objectWillChange.send()
    }
}

public extension Common_PropertyWrappers {
    /// DynamicProperty protocol, which enables automatic view updates when the wrapped value changes
    @propertyWrapper
    struct UserDefaults<T: Codable>: DynamicProperty {
        @ObservedObject var viewUpdateTrigger = ViewUpdateTrigger()
        public let key: String
        public let defaultValue: T
        public var onChange: () -> Void
        public let publisher = PassthroughSubject<T, Never>()
        public init(value: T, key: String, onChange: @escaping () -> Void = {}) {
            self.key = key
            self.defaultValue = value
            self.container = .standard
            self.onChange = onChange
        }

        private let synchronizedQueue = DispatchQueue(
            label: "\(Common.self)_\(Self.self)_\(UUID().uuidString)",
            attributes: .concurrent
        )

        private var container: Foundation.UserDefaults

        /// The underlying value wrapped by the bindable state.
        /// The property that stores the wrapped value of the property. It is the value that is accessed when the property is read or written.
        public var wrappedValue: T {
            get { getWrappedValue() }
            set { setWrappedValue(newValue) }
        }

        /// The projectedValue is an optional property that provides access to the wrapper's "projection" of the wrapped value.
        /// The projection is a separate value that can be used to perform additional operations on the wrapped value.
        /// It is accessed by appending a dollar sign ($) to the property name.
        public var projectedValue: Binding<T> {
            Binding(
                get: { wrappedValue },
                set: { setWrappedValue($0) }
            )
        }

        private func getWrappedValue() -> T {
            synchronizedQueue.sync {
                guard let data = container.data(forKey: key) else {
                    return defaultValue
                }
                let value = try? JSONDecoder().decodeFriendly(T.self, from: data)
                return value ?? defaultValue
            }
        }

        private func setWrappedValue(_ newValue: T) {
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
                    container.removeObject(forKey: key)
                } else {
                    // container.set(to, forKey: key)
                    let data = try? JSONEncoder().encode(newValue)
                    container.setValue(data, forKey: key)
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
    struct UserDefaultsTestViewView: View {
        @AppStorage("myKey1")
        public var text1: String = "default value"

        @Common_PropertyWrappers.UserDefaults(value: "default value", key: "myKey2")
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
    Common_Preview.UserDefaultsTestViewView()
}
#endif
