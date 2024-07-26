//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI
import os

public extension Common {
    class LockManagerV1 {
        public static let shared: LockManagerV1 = {
            // Lazily create the singleton instance
            LockManagerV1()
        }()

        private init() {}
        private var masterLock = NSLock()
        @PWThreadSafe private var lockDictionary: [String: NSLock] = [:]
        @PWThreadSafe private var lockInfoDictionary: [String: LockInfo] = [:]
        public var activeLocksInfo: String {
            var acc: String = ""
            let active = lockDictionary.keys
            acc += " • ActiveLocksCount: \(active.count)\n"
            acc += " • ActiveLocks: \(active)\n"
            return acc
        }

        private struct LockInfo {
            var lockDate: Date?
            var referenceCount: Int
            var unlockTask: DispatchWorkItem?
        }

        private func getLock(for key: String) -> NSLock {
            if let existingLock = lockDictionary[key] {
                return existingLock
            } else {
                let newLock = NSLock()
                lockDictionary[key] = newLock
                lockInfoDictionary[key] = LockInfo(lockDate: Date(), referenceCount: 0)
                return newLock
            }
        }

        @discardableResult
        public func lock(key: String, autoUnlockTimeInSeconds: TimeInterval = 1000) -> String? {
            masterLock.lock()
            defer { masterLock.unlock() }
            let lock = getLock(for: key)
            lock.lock()
            let referenceCount = (lockInfoDictionary[key]?.referenceCount ?? 0) + 1
            lockInfoDictionary[key] = LockInfo(lockDate: Date(), referenceCount: referenceCount, unlockTask: nil)

            if autoUnlockTimeInSeconds > 0 {
                // Schedule an unlock task after the specified time
                let unlockTask = DispatchWorkItem { [weak self] in
                    if let strongSelf = self, let lockInfo = strongSelf.lockInfoDictionary[key], lockInfo.referenceCount > 0 {
                        Common.LogsManager.debug("🔓 \(Self.self): Will auto unlock [\(key)]")
                        strongSelf.unlock(key: key)
                    }
                }
                lockInfoDictionary[key]?.unlockTask = unlockTask
                DispatchQueue.global().asyncAfter(deadline: .now() + autoUnlockTimeInSeconds, execute: unlockTask)
            }
            var emoji = ""
            let totalLocks = lockInfoDictionary.count
            if totalLocks <= 0 {
                emoji = "🟩 \(totalLocks) 🟩"
            } else if totalLocks == 1 {
                emoji = "🟨 \(totalLocks) 🟨"
            } else {
                emoji = "🟥 \(totalLocks) 🟨"
            }
            return "🔒 Locked 🔒 \(key) [RefCount:\(referenceCount)] @ \(Thread.current.queueName) \(emoji)"
        }

        @discardableResult
        public func unlock(key: String) -> String? {
            masterLock.lock()
            defer { masterLock.unlock() }
            let lock = getLock(for: key)
            lock.unlock()
            let referenceCount = (lockInfoDictionary[key]?.referenceCount ?? 0) - 1
            if referenceCount <= 0 {
                lockInfoDictionary[key] = nil
                lockDictionary[key] = nil
            } else {
                lockInfoDictionary[key] = LockInfo(lockDate: Date(), referenceCount: referenceCount)
            }
            var emoji = ""
            let totalLocks = lockInfoDictionary.count
            if totalLocks <= 0 {
                emoji = "🟩 \(totalLocks) 🟩"
            } else if totalLocks == 1 {
                emoji = "🟨 \(totalLocks) 🟨"
            } else {
                emoji = "🟥 \(totalLocks) 🟨"
            }
            return "🔓 Unlocked 🔓 \(key) [RefCount:\(max(referenceCount, 0))] @ \(Thread.current.queueName) \(emoji)"
        }

        public func unlockAll() {
            if !lockDictionary.isEmpty {
                Common.LogsManager.debug("🔓 \(Self.self): Will unlock \(lockDictionary.count) locks. \(lockDictionary). [\(lockDictionary.keys)]")
                lockDictionary.forEach { lock in
                    unlock(key: lock.key)
                }
                if !lockDictionary.isEmpty {
                    unlockAll()
                }
            }
        }
    }
}

//
// MARK: - ThreadSafeV2
//
// https://betterprogramming.pub/mastering-thread-safety-in-swift-with-one-runtime-trick-260c358a7515
//
/**
 On Apple’s platforms, the os_unfair_lock is the most performance-efficient lock available.
 */
public extension Common {
    final class LockManagerV2 {
        public init() {
            self.pointer = .allocate(capacity: 1)
            pointer.initialize(to: os_unfair_lock())
        }

        deinit {
            self.pointer.deinitialize(count: 1)
            self.pointer.deallocate()
        }

        public func lock() {
            os_unfair_lock_lock(pointer)
        }

        public func unlock() {
            os_unfair_lock_unlock(pointer)
        }

        public func tryLock() -> Bool {
            os_unfair_lock_trylock(pointer)
        }

        @discardableResult
        @inlinable
        public func execute<T>(_ action: () -> T) -> T {
            lock(); defer { self.unlock() }
            return action()
        }

        @discardableResult
        @inlinable
        public func tryExecute<T>(_ action: () throws -> T) throws -> T {
            try execute { Result(catching: action) }.get()
        }

        // MARK: Private

        private let pointer: os_unfair_lock_t
    }
}

//
// MARK: - Sample
//

public extension Common.LockManagerV1 {
    static func sampleUsage() {
        // Example usage:
        let lockManager = Common.LockManagerV1.shared
        lockManager.lock(key: #function)
        // Critical section
        lockManager.unlock(key: #function)
    }
}
