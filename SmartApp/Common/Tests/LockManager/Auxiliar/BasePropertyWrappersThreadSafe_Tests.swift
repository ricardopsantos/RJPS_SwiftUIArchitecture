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

protocol TestClassProtocol {
    var value: Int { set get }
    mutating func modify()
}

class BasePropertyWrappersThreadSafe_Tests: XCTestCase {
    func enabled() -> Bool {
        false
    }

    func testClass(value: Int) -> any TestClassProtocol {
        fatalError("Override me")
    }

    func test_resetValues() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var testInstance = testClass(value: 0)

        let incrementIterations = 1_000
        let resetIterations = 10
        let expectation = XCTestExpectation(description: #function)

        DispatchQueue.concurrentPerform(iterations: incrementIterations) { _ in
            testInstance.value += 1
        }

        DispatchQueue.concurrentPerform(iterations: resetIterations) { _ in
            testInstance.value = 0
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(testInstance.value, 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    func test_simultaneousReads() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        let testInstance = testClass(value: 42)

        let iterations = 1_000
        let expectation = XCTestExpectation(description: #function)
        let queue = DispatchQueue(label: #function, attributes: .concurrent)
        var readResults = [Int]()

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            queue.async {
                let value = testInstance.value
                queue.async(flags: .barrier) {
                    readResults.append(value)
                }
            }
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(readResults.count, iterations)
            XCTAssertTrue(readResults.allSatisfy { $0 == 42 })
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    func test_threadSafety() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var testInstance = testClass(value: 0)

        let iterations = 1000
        let expectation = XCTestExpectation(description: #function)
        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            testInstance.value += 1
        }
        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssert(testInstance.value == iterations)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    /**
     This test increases the contention on the property by using a large number of threads that simultaneously read and write to the value.
     The test ensures that all operations complete correctly.
     */
    func test_highContention() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var testInstance = testClass(value: 0)

        let iterations = 10_000
        let expectation = XCTestExpectation(description: #function)
        let queue = DispatchQueue(label: #function, attributes: .concurrent)

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            queue.async {
                testInstance.value += 1
            }
            queue.sync {
                testInstance.value += 1
            }
            queue.async {
                testInstance.value += 1
            }
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(testInstance.value, iterations * 3)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    func test_simultaneousReadsAndWrites() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var testInstance = testClass(value: 0)

        let iterations = 1_000
        let expectation = XCTestExpectation(description: #function)
        let queue = DispatchQueue(label: #function, attributes: .concurrent)
        var readResults = [Int]()

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            queue.async {
                testInstance.value += 1
                let value = testInstance.value
                queue.async(flags: .barrier) {
                    readResults.append(value)
                }
            }
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(readResults.count, iterations)
            XCTAssertEqual(testInstance.value, iterations)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    func test_largeValuesAndOverflow() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var testInstance = testClass(value: Int.max - 1000)

        let iterations = 1_000
        let expectation = XCTestExpectation(description: #function)

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            testInstance.value += 1
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(testInstance.value, Int.max)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }
}
