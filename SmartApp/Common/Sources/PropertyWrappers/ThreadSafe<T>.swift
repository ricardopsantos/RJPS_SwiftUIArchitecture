//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

//
// MARK: - ThreadSafeV1
//
public extension Common_PropertyWrappers {
    @propertyWrapper
    struct ThreadSafeV1<T> {
        private let synchronizedQueue = DispatchQueue(
            label: "\(Common.self)_\(T.self)_\(UUID().uuidString)",
            attributes: .concurrent
        )
        private var objectValue: T!

        public init(wrappedValue value: T) {
            self.objectValue = value
        }

        /// The underlying value wrapped by the bindable state.
        /// The property that stores the wrapped value of the property. It is the value that is accessed when the property is read or written.
        public var wrappedValue: T {
            get { synchronizedQueue.sync { objectValue } }
            set { synchronizedQueue.sync(flags: .barrier) { objectValue = newValue } }
        }
    }
}

fileprivate extension Common_PropertyWrappers.ThreadSafeV1 {
    static func sampleUsage() {
        @Common_PropertyWrappers.ThreadSafeV1 var presentedIDS: [String] = []
    }
}

//
// MARK: - ThreadSafeV2
//
// https://betterprogramming.pub/mastering-thread-safety-in-swift-with-one-runtime-trick-260c358a7515
//
public extension Common_PropertyWrappers {
    final class ThreadSafeV2<T> {
        public init(wrappedValue: T) {
            self.value = wrappedValue
        }

        public var projectedValue: ThreadSafeV2<T> { self }

        // swiftlint:disable implicit_getter
        public var wrappedValue: T {
            get {
                lock.lock(); defer { self.lock.unlock() }
                return value
            }
            _modify {
                self.lock.lock(); defer { self.lock.unlock() }
                yield &self.value
            }
        }

        // swiftlint:enable implicit_getter

        public func read<V>(_ f: (T) -> V) -> V {
            lock.lock(); defer { self.lock.unlock() }
            return f(value)
        }

        @discardableResult
        public func write<V>(_ f: (inout T) -> V) -> V {
            lock.lock(); defer { self.lock.unlock() }
            return f(&value)
        }

        // MARK: Private

        private let lock = Common.LockManagerV2()

        private var value: T
    }
}
