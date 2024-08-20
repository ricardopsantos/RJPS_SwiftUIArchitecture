//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
//
// https://betterprogramming.pub/mastering-thread-safety-in-swift-with-one-runtime-trick-260c358a7515
//
public extension Common_PropertyWrappers {
    /**
     The property wrapper ensures that access to its internal value is synchronized.
     It uses an instance of Common.UnfairLockManager to provide mutual exclusion, preventing data races and ensuring thread safety.
     */
    @propertyWrapper
    final class ThreadSafeUnfairLock<T> {
        private let lock = Common.UnfairLockManager()
        private var value: T

        public init(wrappedValue: T) {
            self.value = wrappedValue
        }

        public var projectedValue: ThreadSafeUnfairLock<T> { self }

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
    }
}

public extension Common_PropertyWrappers {
    /**
     The property wrapper ensures that access to its underlying value is synchronized,
     preventing concurrent read and write operations from causing data races or inconsistent states.
     It uses a DispatchQueue configured for concurrent access to manage thread safety.

     __This FAILS on way more unit tests than `ThreadSafeUnfairLock`__
     */
    @propertyWrapper
    struct ThreadSafeDispatchQueue<T> {
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
