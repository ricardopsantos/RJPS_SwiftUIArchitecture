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
final class Cronometer_Tests: XCTestCase {
    let maxDeviation: Double = 1.01 // 1% error
    override func setUp() {
        super.setUp()
    }

    func test_measure() {
        let operationTime: UInt32 = 1
        let value = Common_CronometerManager.measure {
            sleep(operationTime)
        }
        let maxBond = Double(operationTime) * maxDeviation
        let minBond = Double(operationTime) * (1 - (maxDeviation - 1))
        XCTAssert(value < maxBond && value > minBond)
    }

    func test_timeElapsed() {
        let operationTime: UInt32 = 1
        Common_CronometerManager.startTimerWith()
        sleep(operationTime)
        let value = Common_CronometerManager.timeElapsed() ?? 0
        print("#value: ", value)
        let maxBond = Double(operationTime) * maxDeviation
        let minBond = Double(operationTime) * (1 - (maxDeviation - 1))
        XCTAssert(value < maxBond && value > minBond)
    }
}
