//
//  Created by Ricardo Santos on 12/08/2024.
//

import XCTest
import Foundation
import Combine
//
import Nimble

@testable import Common

class SampleWebAPI_Tests: XCTestCase {
    func enabled() -> Bool {
        true
    }
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        TestsGlobal.loadedAny = nil
        TestsGlobal.cancelBag.cancel()
    }
    
    private var sampleWebAPIUseCase: SampleWebAPIUseCase {
        SampleWebAPIUseCase()
    }
    
    func test_1() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var counter = 0
        sampleWebAPIUseCase.cachedRequest(cachePolicy: .ignoringCache)
            .sinkToReceiveValue { some in
                switch some {
                case .success:
                    counter += 1
                case .failure: ()
                }
            }.store(in: TestsGlobal.cancelBag)
        expect(counter == 1).toEventually(beTrue(), timeout: .seconds(TestsGlobal.timeout))
    }
    
    func test_2() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var counter = 0
        sampleWebAPIUseCase.cachedRequest(cachePolicy: .ignoringCache)
            .sinkToReceiveValue { some in
                switch some {
                case .success:
                    counter += 1
                case .failure: ()
                }
            }.store(in: TestsGlobal.cancelBag)
        expect(counter == 1).toEventually(beTrue(), timeout: .seconds(TestsGlobal.timeout))
    }
}

