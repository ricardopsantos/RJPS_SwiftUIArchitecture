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

class UnfairLockManagerWithKey_Tests: XCTestCase {

    var lockManager: Common.UnfairLockManagerWithKey!

    override func setUp() {
        super.setUp()
        lockManager = Common.UnfairLockManagerWithKey()
    }

    override func tearDown() {
        lockManager = nil
        super.tearDown()
    }

    func testLockUnlock() {
        let expectation = XCTestExpectation(description: "Lock and unlock")
        var value = 0

        lockManager.execute(with: "testKey") {
            value += 1
            XCTAssertEqual(value, 1, "Value should be 1 within the lock")
        }

        DispatchQueue.global().async {
            self.lockManager.execute(with: "testKey") {
                value += 1
                XCTAssertEqual(value, 2, "Value should be 2 within the lock")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testTryLock() {
        let expectation = XCTestExpectation(description: "Try lock")
        var value = 0

        DispatchQueue.global().async {
            if self.lockManager.tryLock(key: "testKey") {
                value += 1
                XCTAssertEqual(value, 1, "Value should be 1 after acquiring the lock")
                self.lockManager.unlock(key: "testKey")
            } else {
                XCTFail("Failed to acquire the lock")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testTryExecute() {
        let expectation = XCTestExpectation(description: "Try execute")
        var value = 0

        DispatchQueue.global().async {
            do {
                let result = try self.lockManager.tryExecute(with: "testKey") {
                    value += 1
                    return value
                }
                XCTAssertEqual(result, 1, "Result should be 1")
                XCTAssertEqual(value, 1, "Value should be 1 after execution")
            } catch {
                XCTFail("tryExecute threw an unexpected error: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testTryExecuteThrowsError() {
        enum TestError: Error {
            case intentionalError
        }

        let expectation = XCTestExpectation(description: "Try execute throws error")

        DispatchQueue.global().async {
            do {
                _ = try self.lockManager.tryExecute(with: "testKey") {
                    throw TestError.intentionalError
                }
                XCTFail("Expected tryExecute to throw an error")
            } catch TestError.intentionalError {
                // Success: Correct error was thrown
                expectation.fulfill()
            } catch {
                XCTFail("Unexpected error thrown: \(error)")
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testThreadSafety() {
        let iterations = 1000
        let expectation = XCTestExpectation(description: "Thread safety")
        var value = 0

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            self.lockManager.execute(with: "testKey") {
                value += 1
            }
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(value, iterations, "Value should be equal to the number of iterations")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2)
    }
}
