//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI
import os

/**
 https://betterprogramming.pub/mastering-thread-safety-in-swift-with-one-runtime-trick-260c358a7515

  On Apple’s platforms, the os_unfair_lock is the most performance-efficient lock available.
  */

public extension Common {
    // A class that provides thread synchronization using os_unfair_lock
    final class UnfairLockManager {
        // Initializes the os_unfair_lock
        public init() {
            self.pointer = .allocate(capacity: 1)
            pointer.initialize(to: os_unfair_lock())
        }

        // Deinitializes and deallocates the os_unfair_lock
        deinit {
            self.pointer.deinitialize(count: 1)
            self.pointer.deallocate()
        }

        // Locks the os_unfair_lock
        public func lock() {
            os_unfair_lock_lock(pointer)
        }

        // Unlocks the os_unfair_lock
        public func unlock() {
            os_unfair_lock_unlock(pointer)
        }

        // Tries to lock the os_unfair_lock and returns true if successful
        public func tryLock() -> Bool {
            os_unfair_lock_trylock(pointer)
        }

        /**
         Executes the provided closure within a lock.
         - Parameter action: The closure to execute.
         - Returns: The result of the closure.
         */
        @discardableResult
        @inlinable
        public func execute<T>(_ action: () -> T) -> T {
            lock(); defer { self.unlock() }
            return action()
        }

        /**
         Tries to execute the provided closure within a lock. If the closure throws an error, it propagates the error.
         - Parameter action: The closure to execute.
         - Returns: The result of the closure.
         - Throws: An error if the closure throws an error.
         */
        @discardableResult
        @inlinable
        public func tryExecute<T>(_ action: () throws -> T) throws -> T {
            try execute { Result(catching: action) }.get()
        }

        // MARK: Private

        // Pointer to the os_unfair_lock
        private let pointer: os_unfair_lock_t
    }
}

public extension Common {
    /// A wrapper class for managing multiple locks with unique IDs.
    final class UnfairLockManagerWithKey {
        // Dictionary to hold locks associated with their keys
        private var locks: [String: UnsafeMutablePointer<os_unfair_lock>] = [:]

        // Initializes the UnfairLockManagerWithKey
        public init() {}

        // Deinitializes and deallocates all os_unfair_locks
        deinit {
            for (_, lockPointer) in locks {
                lockPointer.deinitialize(count: 1)
                lockPointer.deallocate()
            }
        }

        // Retrieves or creates a lock for the given key
        private func lockPointer(for key: String) -> UnsafeMutablePointer<os_unfair_lock> {
            if let lock = locks[key] {
                return lock
            } else {
                let newLockPointer = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
                newLockPointer.initialize(to: os_unfair_lock())
                locks[key] = newLockPointer
                return newLockPointer
            }
        }

        // Locks the os_unfair_lock with the given key
        public func lock(key: String) {
            let pointer = lockPointer(for: key)
            os_unfair_lock_lock(pointer)
        }

        // Unlocks the os_unfair_lock with the given key
        public func unlock(key: String) {
            let pointer = lockPointer(for: key)
            os_unfair_lock_unlock(pointer)
        }

        // Tries to lock the os_unfair_lock with the given key and returns true if successful
        public func tryLock(key: String) -> Bool {
            let pointer = lockPointer(for: key)
            return os_unfair_lock_trylock(pointer)
        }

        /**
         Executes the provided closure within a lock identified by the given key.
         - Parameter key: The key of the lock to be used.
         - Parameter action: The closure to execute within the lock.
         - Returns: The result of the closure.
         */
        @discardableResult
        public func execute<T>(with key: String, _ action: () -> T) -> T {
            lock(key: key)
            defer { unlock(key: key) }
            return action()
        }

        /**
         Tries to execute the provided closure within a lock identified by the given key.
         - Parameter key: The key of the lock to be used.
         - Parameter action: The closure to execute within the lock.
         - Returns: The result of the closure if the lock was successfully acquired.
         - Throws: An error if the closure throws an error.
         */
        @discardableResult
        public func tryExecute<T>(with key: String, _ action: () throws -> T) throws -> T {
            guard tryLock(key: key) else {
                throw LockError.lockNotAcquired
            }
            defer { unlock(key: key) }
            return try action()
        }

        /// Enum representing errors that may occur during lock operations.
        public enum LockError: Error {
            case lockNotAcquired
        }
    }
}
