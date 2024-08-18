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
class Common_BaseOperationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        TestsGlobal.loadedAny = nil
        TestsGlobal.cancelBag.cancel()
        Common.ExecutionControlManager.reset()
    }

    func test_operationPriority() {
        let operation = Common_BaseOperation(priority: .high)
        XCTAssert(operation.queuePriority == .high, "The operation priority should be set to high.")

        operation.setPriority(.low)
        XCTAssert(operation.queuePriority == .low, "The operation priority should be set to low.")

        operation.setPriority(.high)
        XCTAssert(operation.queuePriority == .high, "The operation priority should be set back to high.")
    }

    func test_OperationManagerAddOperationWithPriority() {
        let manager = Common_BaseOperationManager(maxConcurrentOperationCount: 2)

        let highPriorityOperation = Common_BaseOperation(priority: .high)
        let lowPriorityOperation = Common_BaseOperation(priority: .low)

        manager.add(highPriorityOperation)
        manager.add(lowPriorityOperation)

        XCTAssert(highPriorityOperation.queuePriority == .high, "High priority operation should retain its priority.")
        XCTAssert(lowPriorityOperation.queuePriority == .low, "Low priority operation should retain its priority.")
    }

    // Test that operation states update correctly
    func testOperationStateUpdates() {
        let operation = Common_BaseOperation()

        XCTAssertFalse(operation.isExecuting, "Operation should not be executing initially.")
        XCTAssertFalse(operation.isFinished, "Operation should not be finished initially.")

        operation.executing(true)
        XCTAssertTrue(operation.isExecuting, "Operation should be in executing state after calling executing(true).")

        operation.finish(true)
        XCTAssertTrue(operation.isFinished, "Operation should be finished after calling finish(true).")
        XCTAssertFalse(!operation.isExecuting, "Operation should not be executing after being finished.")
    }

    // Test that operations are executed in the correct priority order
    func testOperationExecutionOrder() {
        var operationsOrder: [String] = []

        let manager = Common_BaseOperationManager(maxConcurrentOperationCount: 1)
        let lowPriorityOperation = Common_BaseOperation(name: "low", priority: .low)
        let normalPriorityOperation = Common_BaseOperation(name: "normal", priority: .normal)
        let highPriorityOperation = Common_BaseOperation(name: "high", priority: .high)

        let expectation1 = expectation(description: "low priority operation finish")
        let expectation2 = expectation(description: "normal priority operation finish")
        let expectation3 = expectation(description: "high priority operation finish")

        lowPriorityOperation.operationWork = { Common_Logs.debug("# lowPriorityOperation work") }
        normalPriorityOperation.operationWork = { Common_Logs.debug("# normalPriorityOperation work") }
        highPriorityOperation.operationWork = { Common_Logs.debug("# highPriorityOperation work") }

        lowPriorityOperation.completionBlock = {
            operationsOrder.append(lowPriorityOperation.operationName)
            expectation1.fulfill()
        }

        normalPriorityOperation.completionBlock = {
            operationsOrder.append(normalPriorityOperation.operationName)
            expectation2.fulfill()
        }

        highPriorityOperation.completionBlock = {
            operationsOrder.append(highPriorityOperation.operationName)
            expectation3.fulfill()
        }

        manager.addMultiple([lowPriorityOperation, normalPriorityOperation, highPriorityOperation])

        wait(for: [expectation1, expectation2, expectation3], timeout: TimeInterval(TestsGlobal.timeout))
        let operations = manager.queue.operations
        XCTAssert(operationsOrder.first == highPriorityOperation.operationName)
        XCTAssert(operationsOrder.last == lowPriorityOperation.operationName)
        XCTAssertNotNil(operations, "Operations should not be nil")
        XCTAssert(operations.isEmpty, "All operations should be finished.")
    }
}
