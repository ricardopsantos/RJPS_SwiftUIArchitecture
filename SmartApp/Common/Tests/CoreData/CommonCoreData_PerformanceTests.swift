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
class CommonCoreData_PerformanceTests: XCTestCase {
    let iterations = 20
    let maxDeviation = 1.1
    let stressLoadValue = 1_000

    func enabled() -> Bool {
        true
    }

    var bd: CommonCoreData.Utils.Sample.CRUDEntityDBRepository = {
        .shared
    }()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        TestsGlobal.loadedAny = nil
        TestsGlobal.cancelBag.cancel()
    }

    func test_bulkInsertSinglePerformance() {
        guard enabled() else {
            XCTAssert(true)
            return
        }

        bd.syncClearAll()

        let expectedTime: Double = [0.6013554334640503, 0.943675059080124, 0.9092829048633575].max()!
        let expectation = expectation(description: #function)
        var averageTime: Double = 0
        averageOperationTime(iterations: iterations) {
            bd.syncClearAll()
        } operation: {
            _ = (1...stressLoadValue).map { _ in bd.syncStore(.random) }
        } onComplete: { avg in
            averageTime = avg
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: expectedTime * Double(iterations) * maxDeviation)
        Common_Logs.debug("# Average \(#function): \(averageTime)")
        XCTAssert(averageTime < expectedTime * maxDeviation) // Allow a max of 10% increase comparing to expected value
    }

    func test_bulkInsertBatchPerformance() {
        guard enabled() else {
            XCTAssert(true)
            return
        }

        bd.syncClearAll()

        let expectedTime: Double = [0.0063312768936157225, 0.006880849599838257, 0.006965309381484985].max()!
        let expectation = expectation(description: #function)
        var averageTime: Double = 0
        let records: [CommonCoreData.Utils.Sample.CRUDEntity] = (1...stressLoadValue).map { _ in .random }
        averageOperationTime(iterations: iterations) {
            bd.syncClearAll()
        } operation: {
            bd.syncStoreBatch(records)
        } onComplete: { avg in
            averageTime = avg
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: expectedTime * Double(iterations) * maxDeviation)
        Common_Logs.debug("# Average \(#function): \(averageTime)")
        XCTAssert(averageTime < expectedTime * maxDeviation) // Allow a max of 10% increase comparing to expected value
    }

    func test_deletePerformance() {
        guard enabled() else {
            XCTAssert(true)
            return
        }

        bd.syncClearAll()

        let expectedTime: Double = [0.0007933318614959717, 0.0010145127773284913, 0.0004244029521942139].max()!

        let expectation = expectation(description: #function)
        var averageTime: Double = 0
        averageOperationTime(iterations: iterations) {
            bd.syncStoreBatch((1...stressLoadValue).map { _ in .random })
        } operation: {
            bd.syncClearAll()
        } onComplete: { avg in
            averageTime = avg
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: expectedTime * Double(iterations) * maxDeviation)
        Common_Logs.debug("# Average \(#function): \(averageTime)")
        XCTAssert(averageTime < expectedTime * maxDeviation) // Allow a max of 10% increase comparing to expected value
    }
}
