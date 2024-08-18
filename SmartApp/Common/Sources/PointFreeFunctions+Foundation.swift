//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

/// Synchronizes access to a critical section of code using either Objective-C synchronization or a Swift-native NSLock, depending on the type of lock provided.
///
/// - Parameters:
///   - lock: The lock object to synchronize on.
///   - closure: The closure containing the code to be synchronized.
/// - Returns: The result of the closure.
public func synced<T>(_ lock: Any, closure: () -> T) -> T {
    if let nsLock = lock as? NSLock {
        syncedV2(nsLock, closure: closure)
    } else {
        syncedV1(lock, closure: closure)
    }
}

// Define a wrapper for weak reference
public class Weak<T: AnyObject> {
    public weak var value: T?
    public init(_ value: T?) {
        self.value = value
    }
}

/// Synchronizes access to a critical section of code using Objective-C synchronization.
///
/// - Parameters:
///   - lock: The lock object to synchronize on.
///   - closure: The closure containing the code to be synchronized.
/// - Returns: The result of the closure.
/// - It requires passing a lock object of type Any, which can be any object that can serve as a synchronization point.
/// - The closure containing the synchronized code is passed as an argument.
/// - It's less type-safe because it can accept any object as the lock.
/// - It's slightly less efficient than Swift-native synchronization due to the overhead of Objective-C runtime functions.
public func syncedV1<T>(_ lock: Any, closure: () -> T) -> T {
    /** Usage:
     ```
     let lock = NSObject()
     syncedV1(lock) {
         // Critical section
     }
     ```
     */
    objc_sync_enter(lock)
    let r = closure()
    objc_sync_exit(lock)
    return r
}

/// Synchronizes access to a critical section of code using a Swift-native NSLock.
///
/// - Parameters:
///   - lock: The NSLock object to synchronize on.
///   - closure: The closure containing the code to be synchronized.
/// - Returns: The result of the closure.
/// - It requires passing an NSLock instance explicitly.
/// - The closure containing the synchronized code is passed as an argument.
/// - It's more type-safe because it explicitly requires an NSLock instance.
/// - It's slightly more efficient than Objective-C synchronization because it directly calls Swift methods.
/// - defer { lock.unlock() } ensures that the lock is always released, even if an error occurs or an early return is encountered.
public func syncedV2<T>(_ lock: NSLock, closure: () -> T) -> T {
    /** Usage:
     ```
     let lock = NSObject()
     syncedV2(lock) {
         // Critical section
     }
     ```
     */
    lock.lock(); defer { lock.unlock() }
    return closure()
}
