import XCTest
import Foundation
import Combine
//
import Nimble

//
// Don't run directly! Run in SubClasses
// Don't run directly! Run in SubClasses
// Don't run directly! Run in SubClasses
//
@testable import Common
class SyncCodableCacheManagerBase_Tests: XCTestCase {
    func enabled() -> Bool {
        // Override with implementation
        false
    }

    func codableCacheManager() -> CodableCacheManagerProtocol {
        // Override with implementation
        fatalError()
    }

    private var sampleWebAPIUseCase: SampleWebAPIUseCase {
        SampleWebAPIUseCase()
    }
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        TestsGlobal.loadedAny = nil
        TestsGlobal.cancelBag.cancel()
    }

    func test_aSyncCRUD() async {
        guard enabled() else {
            XCTAssert(true)
            return
        }

        let model = SampleCodableStruct.random
        let key = String.random(10)
        let params = [model.age.description, model.name]

        // Store records
        await codableCacheManager().aSyncStore(model, key: key, params: params, timeToLiveMinutes: nil)

        if let cached = await codableCacheManager().aSyncRetrieve(
            SampleCodableStruct.self,
            key: key,
            params: params
        ) {
            // Assert that the record was stored and the info matches
            XCTAssert(cached.model == model)
        } else {
            XCTAssert(false)
        }

        // Delete cache
        await codableCacheManager().aSyncClearAll()

        if await codableCacheManager().aSyncRetrieve(
            SampleCodableStruct.self,
            key: key,
            params: params
        ) != nil {
            XCTAssert(false)
        } else {
            // Assert that that the object was deleted
            XCTAssert(true)
        }
    }

    func test_syncCRUD() {
        guard enabled() else {
            XCTAssert(true)
            return
        }

        let model = SampleCodableStruct.random
        let key = String.random(10)
        let params = [model.age.description, model.name]

        // Store records
        codableCacheManager().syncStore(model, key: key, params: params, timeToLiveMinutes: nil)

        if let cached = codableCacheManager().syncRetrieve(
            SampleCodableStruct.self,
            key: key,
            params: params
        ) {
            // Assert that the record was stored and the info matches
            XCTAssert(cached.model == model)
        } else {
            XCTAssert(false)
        }

        // Delete cache
        codableCacheManager().syncClearAll()

        if codableCacheManager().syncRetrieve(
            SampleCodableStruct.self,
            key: key,
            params: params
        ) != nil {
            XCTAssert(false)
        } else {
            // Assert that that the object was deleted
            XCTAssert(true)
        }
    }

    func test_cachePolicy_ignoringCache() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var counter = 0
        syncClearAll()
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

    func test_cacheElseLoad() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var counter = 0
        syncClearAll()
        sampleWebAPIUseCase.cachedRequest(cachePolicy: .cacheElseLoad)
            .sinkToReceiveValue { some in
                switch some {
                case .success:
                    counter += 1
                case .failure: ()
                }
            }.store(in: TestsGlobal.cancelBag)
        expect(counter == 1).toEventually(beTrue(), timeout: .seconds(TestsGlobal.timeout))
    }

    func test_cacheDontLoad() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var counter = 0
        syncClearAll()
        sampleWebAPIUseCase.cachedRequest(cachePolicy: .cacheDontLoad)
            .sinkToReceiveValue { some in
                switch some {
                case .success:
                    counter += 1
                case .failure: ()
                }
            }.store(in: TestsGlobal.cancelBag)
        expect(counter == 0).toEventually(beTrue(), timeout: .seconds(TestsGlobal.timeout))
    }

    func test_cacheAndLoadT1() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var counter = 0
        syncClearAll()
        sampleWebAPIUseCase.cachedRequest(cachePolicy: .cacheAndLoad)
            .sinkToReceiveValue { some in
                switch some {
                case .success:
                    counter += 1
                case .failure: ()
                }
            }.store(in: TestsGlobal.cancelBag)
        expect(counter == 1).toEventually(beTrue(), timeout: .seconds(TestsGlobal.timeout))
    }

    func test_cacheAndLoadT2() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var counter = 0
        syncClearAll()
        sampleWebAPIUseCase.cachedRequest(cachePolicy: .ignoringCache)
            .sinkToReceiveValue { some in
                switch some {
                case .success:
                    self.sampleWebAPIUseCase.cachedRequest(cachePolicy: .cacheAndLoad)
                        .sinkToReceiveValue { some in
                            switch some {
                            case .success:
                                counter += 1
                            case .failure: ()
                            }
                        }.store(in: TestsGlobal.cancelBag)
                case .failure: ()
                }
            }.store(in: TestsGlobal.cancelBag)
        expect(counter == 2).toEventually(beTrue(), timeout: .seconds(TestsGlobal.timeout))
    }

    func test_fetchingRecordFrom_10000Records() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        syncClearAll()
        syncStore(count: 10000)
        measure {
            // Time: 0.004 sec
            syncFetchFirst()
        }
    }
}

//
// MARK: Auxiliar
//

private extension SyncCodableCacheManagerBase_Tests {
    func syncStore(count: Int) {
        for i in 0...count {
            codableCacheManager().syncStore(
                SampleCodableStruct.random,
                key: "cachedKey_\(i)",
                params: [],
                timeToLiveMinutes: nil
            )
        }
    }

    func syncFetchFirst() {
        if codableCacheManager().syncRetrieve(
            SampleCodableStruct.self,
            key: "cachedKey_0",
            params: []
        ) != nil {
        } else {
            XCTAssert(false)
        }
    }

    func syncClearAll() {
        codableCacheManager().syncClearAll()
    }
}
