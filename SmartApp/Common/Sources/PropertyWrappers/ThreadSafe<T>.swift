//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

//
// MARK: - ThreadSafeV2
//
// https://betterprogramming.pub/mastering-thread-safety-in-swift-with-one-runtime-trick-260c358a7515
//
public extension Common_PropertyWrappers {
    
    @propertyWrapper
    final class ThreadSafe<T> {
        
        private let lock = Common.UnfairLockManager()
        private var value: T
        
        public init(wrappedValue: T) {
            self.value = wrappedValue
        }

        public var projectedValue: ThreadSafe<T> { self }

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
