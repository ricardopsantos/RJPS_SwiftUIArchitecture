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

final class UnfairLockManager_Tests: XCTestCase {
    let lockManager = Common.UnfairLockManager()

    func testLockUnlock() {
        var value = 0
        lockManager.lock()
        value += 1
        XCTAssert(value == 1)
        lockManager.unlock()
    }

    func testTryLock() {
        var value = 0
        XCTAssert(lockManager.tryLock())
        value += 1
        XCTAssert(value == 1)
        lockManager.unlock()
    }

    func testExecute() {
        var value = 0
        let result = lockManager.execute {
            value += 1
            return value
        }
        XCTAssert(result == 1)
        XCTAssert(value == 1)
    }

    func testTryExecute() {
        var value = 0
        do {
            let result = try lockManager.tryExecute {
                value += 1
                return value
            }
            XCTAssert(result == 1)
            XCTAssert(value == 1)
        } catch {
            XCTFail("tryExecute threw an unexpected error: \(error)")
        }
    }

    func testTryExecuteThrowsError() {
        enum TestError: Error {
            case intentionalError
        }

        do {
            _ = try lockManager.tryExecute {
                throw TestError.intentionalError
            }
            XCTFail("Expected tryExecute to throw an error")
        } catch TestError.intentionalError {
            // Success: Correct error was thrown
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    // Perform 1000 writes concurrently
    func testThreadSafety() {
        var value = 0
        let iterations = 1000
        let expectation = XCTestExpectation(description: #function)
        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            lockManager.execute {
                value += 1
            }
        }
        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssert(value == iterations)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    func test_highContentionWithMultipleLocks() {
        var value = 0
        let iterations = 10_000
        let expectation = XCTestExpectation(description: #function)
        let queue = DispatchQueue(label: #function, attributes: .concurrent)

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            queue.async {
                self.lockManager.lock()
                value += 1
                self.lockManager.unlock()
            }
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(value, iterations)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    func test_deadlockPrevention() {
        let expectation = XCTestExpectation(description: #function)

        let queue1 = DispatchQueue(label: "com.test.queue1")
        let queue2 = DispatchQueue(label: "com.test.queue2")

        queue1.async {
            self.lockManager.lock()
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                self.lockManager.unlock()
            }
        }

        queue2.async {
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) {
                self.lockManager.lock()
                self.lockManager.unlock()
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    func test_stressTestWithLargeNumberOfOperations() {
        var value = 0
        let iterations = 100_000
        let expectation = XCTestExpectation(description: #function)

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            lockManager.execute {
                value += 1
            }
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            XCTAssertEqual(value, iterations)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    func test_concurrentExecutionWithDelays() {
        var value = 0
        let iterations = 100
        let expectation = XCTestExpectation(description: #function)
        let queue = DispatchQueue(label: "delayedExecutionQueue", attributes: .concurrent)

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            queue.async {
                self.lockManager.execute {
                    let currentValue = value
                    Thread.sleep(forTimeInterval: 0.01)
                    value = currentValue + 1
                }
            }
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            XCTAssertEqual(value, iterations)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    // FAILS!
    // XCTAssertEqual failed: ("9860") is not equal to ("10000")
    func test_FAIL_highContentionWithTryLock() {
        var successCount = 0
        var failureCount = 0
        let iterations = 10_000
        let expectation = XCTestExpectation(description: #function)
        let queue = DispatchQueue(label: #function, attributes: .concurrent)

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            queue.async {
                if self.lockManager.tryLock() {
                    successCount += 1
                    self.lockManager.unlock()
                } else {
                    failureCount += 1
                }
            }
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            print(successCount, failureCount)
            XCTAssertEqual(successCount + failureCount, iterations) // FAILS ("9860") is not equal to ("10000")
            XCTAssertGreaterThan(successCount, 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    func test_FAIL_simultaneousReadsAndWritesWithLock() {
        var value = 0
        let iterations = 1_000
        let expectation = XCTestExpectation(description: #function)
        let queue = DispatchQueue(label: #function, attributes: .concurrent)
        var readResults = [Int]()

        DispatchQueue.concurrentPerform(iterations: iterations) { i in
            queue.async {
                self.lockManager.lock()
                value += 1
                self.lockManager.unlock()

                self.lockManager.lock()
                let readValue = value
                self.lockManager.unlock()

                queue.async(flags: .barrier) {
                    readResults.append(readValue)
                }
            }
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(readResults.count, iterations)
            XCTAssertEqual(value, iterations)
            XCTAssertTrue(readResults.allSatisfy { $0 == readResults.first })
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }
}
