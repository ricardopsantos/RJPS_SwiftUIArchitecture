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

class PropertyWrappersThreadSafe_Tests: XCTestCase {

    struct TestClass {
        @Common_PropertyWrappers.ThreadSafe var threadSafeV1Value: Int
        @Common_PropertyWrappers.ThreadSafe var threadSafeV2Value: Int
    }

    func testThreadSafety() {
        let testInstance = TestClass(threadSafeV1Value: 0, threadSafeV2Value: 0)

        let iterations = 1000
        let expectation = XCTestExpectation(description: #function)
        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            testInstance.threadSafeV1Value += 1
            testInstance.threadSafeV2Value += 1
        }
        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            print(testInstance.threadSafeV1Value)
            print(testInstance.threadSafeV2Value)
            XCTAssert(testInstance.threadSafeV2Value == iterations)
            XCTAssert(testInstance.threadSafeV1Value == iterations)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))

    }
    
    /**
     This test increases the contention on the property by using a large number of threads that simultaneously read and write to the value.
     The test ensures that all operations complete correctly.
     */
    func test_highContention() {
        let testInstance = TestClass(threadSafeV1Value: 0, threadSafeV2Value: 0)

        let iterations = 10_000
        let expectation = XCTestExpectation(description: #function)
        let queue = DispatchQueue(label: #function, attributes: .concurrent)

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            queue.async {
                testInstance.threadSafeV1Value += 1
                testInstance.threadSafeV2Value += 1
            }
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(testInstance.threadSafeV2Value, iterations)
            XCTAssertEqual(testInstance.threadSafeV1Value, iterations)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }
    
    func test_simultaneousReads() {
        let testInstance = TestClass(threadSafeV1Value: 42, threadSafeV2Value: 42)

        let iterations = 1_000
        let expectation = XCTestExpectation(description: #function)
        let queue = DispatchQueue(label: #function, attributes: .concurrent)
        var readResultsV1 = [Int]()
        var readResultsV2 = [Int]()

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            queue.async {
                let valueV1 = testInstance.threadSafeV1Value
                let valueV2 = testInstance.threadSafeV2Value
                queue.async(flags: .barrier) {
                    readResultsV1.append(valueV1)
                    readResultsV2.append(valueV2)
                }
            }
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(readResultsV1.count, iterations)
            XCTAssertEqual(readResultsV2.count, iterations)
            XCTAssertTrue(readResultsV1.allSatisfy { $0 == 42 })
            XCTAssertTrue(readResultsV2.allSatisfy { $0 == 42 })
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    func test_simultaneousReadsAndWrites() {
        let testInstance = TestClass(threadSafeV1Value: 0, threadSafeV2Value: 0)

        let iterations = 1_000
        let expectation = XCTestExpectation(description: #function)
        let queue = DispatchQueue(label: #function, attributes: .concurrent)
        var readResultsV1 = [Int]()
        var readResultsV2 = [Int]()

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            queue.async {
                testInstance.threadSafeV1Value += 1
                testInstance.threadSafeV2Value += 1
                let valueV1 = testInstance.threadSafeV1Value
                let valueV2 = testInstance.threadSafeV2Value
                queue.async(flags: .barrier) {
                    readResultsV1.append(valueV1)
                    readResultsV2.append(valueV2)
                }
            }
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(readResultsV1.count, iterations)
            XCTAssertEqual(readResultsV2.count, iterations)
            XCTAssertEqual(testInstance.threadSafeV1Value, iterations)
            XCTAssertEqual(testInstance.threadSafeV2Value, iterations)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    func test_resetValues() {
        let testInstance = TestClass(threadSafeV1Value: 0, threadSafeV2Value: 0)

        let incrementIterations = 1_000
        let resetIterations = 10
        let expectation = XCTestExpectation(description: #function)

        DispatchQueue.concurrentPerform(iterations: incrementIterations) { _ in
            testInstance.threadSafeV1Value += 1
            testInstance.threadSafeV2Value += 1
        }

        DispatchQueue.concurrentPerform(iterations: resetIterations) { _ in
            testInstance.threadSafeV1Value = 0
            testInstance.threadSafeV2Value = 0
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(testInstance.threadSafeV1Value, 0)
            XCTAssertEqual(testInstance.threadSafeV2Value, 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    func test_largeValuesAndOverflow() {
        let testInstance = TestClass(threadSafeV1Value: Int.max - 1000, threadSafeV2Value: Int.max - 1000)

        let iterations = 1_000
        let expectation = XCTestExpectation(description: #function)

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            testInstance.threadSafeV1Value += 1
            testInstance.threadSafeV2Value += 1
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(testInstance.threadSafeV1Value, Int.max)
            XCTAssertEqual(testInstance.threadSafeV2Value, Int.max)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }

    func test_complexDataStructures() {
        struct TestComplexClass {
            @Common_PropertyWrappers.ThreadSafe var threadSafeArrayV1: [Int]
            @Common_PropertyWrappers.ThreadSafe var threadSafeArrayV2: [Int]
        }

        let testInstance = TestComplexClass(threadSafeArrayV1: [], threadSafeArrayV2: [])

        let iterations = 1_000
        let expectation = XCTestExpectation(description: #function)

        DispatchQueue.concurrentPerform(iterations: iterations) { i in
            testInstance.threadSafeArrayV1.append(i)
            testInstance.threadSafeArrayV2.append(i)
        }

        // Allow some time for the concurrent operations to finish
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(testInstance.threadSafeArrayV1.count, iterations)
            XCTAssertEqual(testInstance.threadSafeArrayV2.count, iterations)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TimeInterval(TestsGlobal.timeout))
    }


}
