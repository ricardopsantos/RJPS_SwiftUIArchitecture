//
//  Created by Ricardo Santos on 12/08/2024.
//

import XCTest
import Foundation
import Combine
//
import Nimble
//
@testable import Common

//
// MARK: - ThreadSafeUnfairLock
//

struct TestClassThreadSafeUnfairLock: TestClassProtocol {
    @Common_PropertyWrappers.ThreadSafeUnfairLock var threadSafeValue: Int
}

class PropertyWrappers_ThreadSafeUnfairLock_Tests: BasePropertyWrappersThreadSafe_Tests {
    override func enabled() -> Bool {
        return true
    }
    override func testClass(threadSafeValue: Int) -> any TestClassProtocol {
        TestClassThreadSafeUnfairLock(threadSafeValue: threadSafeValue)
    }
}

//
// MARK: - ThreadSafeUnfairLock
//
struct TestClasseThreadSafeDispatchQueue: TestClassProtocol {
    @Common_PropertyWrappers.ThreadSafeDispatchQueue var threadSafeValue: Int
}

class PropertyWrappers_ThreadSafeDispatchQueue_Tests: BasePropertyWrappersThreadSafe_Tests {
    override func enabled() -> Bool {
        return true
    }
    override func testClass(threadSafeValue: Int) -> any TestClassProtocol {
        TestClasseThreadSafeDispatchQueue(threadSafeValue: threadSafeValue)
    }
}
