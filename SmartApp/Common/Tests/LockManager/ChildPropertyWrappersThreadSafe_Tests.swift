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

class PropertyWrappers_ThreadSafeUnfairLock_Tests: BasePropertyWrappersThreadSafe_Tests {
    struct TestClass: TestClassProtocol {
        @Common_PropertyWrappers.ThreadSafeUnfairLock var value: Int
        mutating func modify() {
            _ = value
            value = .random(in: 0...1000)
        }
    }

    override func enabled() -> Bool {
        true
    }

    override func testClass(value: Int) -> any TestClassProtocol {
        TestClass(value: value)
    }
}

//
// MARK: - ThreadSafeDispatchQueue
//

class PropertyWrappers_ThreadSafeDispatchQueue_Tests: BasePropertyWrappersThreadSafe_Tests {
    struct TestClass: TestClassProtocol {
        @Common_PropertyWrappers.ThreadSafeDispatchQueue var value: Int
        mutating func modify() {
            _ = value
            value = .random(in: 0...1000)
        }
    }

    override func enabled() -> Bool {
        true
    }

    override func testClass(value: Int) -> any TestClassProtocol {
        TestClass(value: value)
    }
}

//
// MARK: - TestClass (not tread safe)
//

class PropertyWrappers_TestClass_Tests: BasePropertyWrappersThreadSafe_Tests {
    struct TestClass: TestClassProtocol {
        var value: Int
        mutating func modify() {
            _ = value
            value = .random(in: 0...1000)
        }
    }

    override func enabled() -> Bool {
        true
    }

    override func testClass(value: Int) -> any TestClassProtocol {
        TestClass(value: value)
    }
}
