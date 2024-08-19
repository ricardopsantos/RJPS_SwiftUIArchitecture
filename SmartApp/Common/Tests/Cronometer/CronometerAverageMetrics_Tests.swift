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
final class CronometerAverageMetrics_Tests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Reset the shared instance before each test to ensure a clean state.
        CronometerAverageMetrics.shared.clear()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_basicUsageSingleOperation() {
        let key = "testOperation"
        
        // Start the timer
        CronometerAverageMetrics.shared.start(key: key)
        
        usleep(useconds_t(1 * 1000_000)) // Sleep for 1 second
        
        // End the timer and retrieve the elapsed time
        let operationElapsedTime = CronometerAverageMetrics.shared.end(key: key)
        let operationElapsedTimeOnRange = timeInOnRange(value: operationElapsedTime, refValue: 1)
        XCTAssert(operationElapsedTimeOnRange)
    }
    
    func test_basicUsageMultipleOperationsT1() {
        let key = "testOperation"
        
        let time1InSeconds: Double = Double(Int.random(in: 1...3))
        let time2InSeconds: Double = Double(Int.random(in: 1...3))
        let time3InSeconds: Double = Double(Int.random(in: 1...3))
        
        performOperation(key: key, timeInSeconds: time1InSeconds)
        performOperation(key: key, timeInSeconds: time2InSeconds)
        performOperation(key: key, timeInSeconds: time3InSeconds)
        
        // End the timer and retrieve the elapsed time
        let averageTimeReceived = CronometerAverageMetrics.shared.averageTimeFor(key: key)
        let averageTimeExpected = (time1InSeconds + time2InSeconds + time3InSeconds) / 3.0
        let averageTimeOnRange = timeInOnRange(value: averageTimeReceived, refValue: averageTimeExpected)
        XCTAssert(averageTimeOnRange)
    }
    
    func testReportV1() {
        let key1 = "testOperation1"
        let key2 = "testOperation2"
        
        let time1InSeconds: Double = Double(Int.random(in: 1...3))
        let time2InSeconds: Double = Double(Int.random(in: 1...3))
        let time3InSeconds: Double = Double(Int.random(in: 1...3))
        
        performOperation(key: key1, timeInSeconds: time1InSeconds)
        performOperation(key: key1, timeInSeconds: time2InSeconds)
        performOperation(key: key1, timeInSeconds: time3InSeconds)
        
        performOperation(key: key2, timeInSeconds: time1InSeconds)
        performOperation(key: key2, timeInSeconds: time2InSeconds)
        performOperation(key: key2, timeInSeconds: time3InSeconds)
        
        // Generate reportV1
        let report = CronometerAverageMetrics.shared.reportV1
        
        // Check the report contents
        let key1Metrics = report[key1] as? [String: String]
        let key1MetricsAverageTime: Double = key1Metrics?["avg"]?.doubleValue ?? 0.0
        
        let key2Metrics = report[key2] as? [String: String]
        let key2MetricsAverageTime: Double = key2Metrics?["avg"]?.doubleValue ?? 0.0
        
        let averageTimeExpected = (time1InSeconds + time2InSeconds + time3InSeconds) / 3.0
        
        let key1AverageTimeOnRange = timeInOnRange(
            value: key1MetricsAverageTime,
            refValue: averageTimeExpected
        )
        let key2AverageTimeOnRange = timeInOnRange(
            value: key2MetricsAverageTime,
            refValue: averageTimeExpected
        )
        
        XCTAssert(key1Metrics?["total"]?.intValue == 3)
        XCTAssert(key2Metrics?["total"]?.intValue == 3)
        XCTAssert(key1AverageTimeOnRange)
        XCTAssert(key2AverageTimeOnRange)
    }
}

extension CronometerAverageMetrics_Tests {
    @discardableResult
    private func performOperation(key: String, timeInSeconds: Double) -> Double {
        CronometerAverageMetrics.shared.start(key: key)
        usleep(useconds_t(timeInSeconds * 1000_000))
        return CronometerAverageMetrics.shared.end(key: key)
    }
    
    private func timeInOnRange(value: Double, refValue: Double) -> Bool {
        let k: Double = 0.01 // 10% deviation
        if refValue > value * (1 + k) {
            return false
        }
        if refValue < value * (1 - k) {
            return false
        }
        return true
    }
}
