//
//  Created by Ricardo Santos on 12/08/2024.
//

import XCTest
import Foundation
import Combine
//
import Nimble

@testable import Common
class ExecutionControlManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        TestsGlobal.loadedAny = nil
        TestsGlobal.cancelBag.cancel()
        Common.ExecutionControlManager.reset()
    }

    func testThrottle() {
        var executionCount = 0
        let operationId = #function
        let timeInterval: Double = 1
        // Call throttle function and expect closure to be executed
        Common.ExecutionControlManager.throttle(timeInterval, operationId: operationId) {
            executionCount += 1 // Should execute
        }

        // Call throttle function again within the throttle interval, expect closure not to be executed
        Common.ExecutionControlManager.throttle(timeInterval - 0.1, operationId: operationId) {
            executionCount += 1 // Should not execute
        }

        // After waiting for the throttle interval, call throttle again and expect closure to be executed
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval + 0.1) {
            Common.ExecutionControlManager.throttle(1, operationId: operationId) {
                executionCount += 1 // Should execute
            }
        }

        // Test assertions
        let timeout = NimbleTimeInterval.seconds(Int(timeInterval * 2))
        expect(executionCount).toEventually(equal(2), timeout: timeout)
    }

    func testThrottleWithIgnoredClosure() {
        var executionCount = 0
        var ignoredCount = 0
        let operationId = #function
        let timeInterval: Double = 1

        // Call throttle with an ignored closure
        Common.ExecutionControlManager.throttle(timeInterval, operationId: operationId, closure: {
            executionCount += 1
        }, onIgnoredClosure: {
            ignoredCount += 1
        })

        // Call throttle again within the throttle interval, expect the ignored closure to be executed
        Common.ExecutionControlManager.throttle(timeInterval, operationId: operationId, closure: {
            executionCount += 1
        }, onIgnoredClosure: {
            ignoredCount += 1
        })

        // Test assertions
        let timeout = NimbleTimeInterval.seconds(Int(timeInterval * 2))
        expect(executionCount).toEventually(equal(1), timeout: timeout)
        expect(ignoredCount).toEventually(equal(1), timeout: timeout)
    }

    func testDebounce() {
        var executionCount = 0
        let operationId = #function
        let timeInterval: Double = 1

        // Call debounce function multiple times in quick succession
        Common.ExecutionControlManager.debounce(timeInterval, operationId: operationId) {
            executionCount += 1 // Should not execute
        }
        Common.ExecutionControlManager.debounce(timeInterval, operationId: operationId) {
            executionCount += 1 // Should not execute
        }
        Common.ExecutionControlManager.debounce(timeInterval, operationId: operationId) {
            executionCount += 1 // Should execute
        }

        // Expect only one closure execution after debounce interval
        let timeoutT1 = NimbleTimeInterval.seconds(Int(timeInterval + 1))
        expect(executionCount).toEventually(equal(1), timeout: timeoutT1)

        // Call debounce again after a delay and expect another execution
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval + 0.1) {
            Common.ExecutionControlManager.debounce(1, operationId: operationId) {
                executionCount += 1 // Should execute
            }
        }

        // Test assertions
        let timeoutT2 = NimbleTimeInterval.seconds(Int(timeInterval + 2))
        expect(executionCount).toEventually(equal(2), timeout: timeoutT2)
    }
}
