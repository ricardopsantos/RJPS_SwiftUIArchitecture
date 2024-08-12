import XCTest
import Foundation
import Combine
//
import Nimble

//
// Dont run directly! Run in SubClasses
// Dont run directly! Run SubClasses
// Dont run directly! Run SubClasses
//
@testable import Common
class SyncCodableCacheManagerBase_Tests: XCTestCase {
    func enabled() -> Bool {
        // Override with implementation
        fatalError()
    }

    func codableCacheManager() -> CodableCacheManagerProtocol {
        // Override with implementation
        fatalError()
    }

    private var service: NetworkAgentSampleAPIProtocol {
        SimpleNetworkAgentSampleAPI(session: .defaultForNetworkAgent)
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        loadedAny = nil
        cancelBag.cancel()
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
        cachedRequest(cachePolicy: .ignoringCache)?
            .sinkToReceiveValue { some in
                switch some {
                case .success:
                    counter += 1
                case .failure: ()
                }
            }.store(in: cancelBag)
        expect(counter == 1).toEventually(beTrue(), timeout: .seconds(timeout))
    }

    func test_cacheElseLoad() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var counter = 0
        syncClearAll()
        cachedRequest(cachePolicy: .cacheElseLoad)?
            .sinkToReceiveValue { some in
                switch some {
                case .success:
                    counter += 1
                case .failure: ()
                }
            }.store(in: cancelBag)
        expect(counter == 1).toEventually(beTrue(), timeout: .seconds(timeout))
    }

    func test_cacheDontLoad() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var counter = 0
        syncClearAll()
        cachedRequest(cachePolicy: .cacheDontLoad)?
            .sinkToReceiveValue { some in
                switch some {
                case .success:
                    counter += 1
                case .failure: ()
                }
            }.store(in: cancelBag)
        expect(counter == 0).toEventually(beTrue(), timeout: .seconds(timeout))
    }

    func test_cacheAndLoadT1() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var counter = 0
        syncClearAll()
        cachedRequest(cachePolicy: .cacheAndLoad)?
            .sinkToReceiveValue { some in
                switch some {
                case .success:
                    counter += 1
                case .failure: ()
                }
            }.store(in: cancelBag)
        expect(counter == 1).toEventually(beTrue(), timeout: .seconds(timeout))
    }

    func test_cacheAndLoadT2() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        var counter = 0
        syncClearAll()
        cachedRequest(cachePolicy: .ignoringCache)?
            .sinkToReceiveValue { some in
                switch some {
                case .success:
                    self.cachedRequest(cachePolicy: .cacheAndLoad)?
                        .sinkToReceiveValue { some in
                            switch some {
                            case .success:
                                counter += 1
                            case .failure: ()
                            }
                        }.store(in: cancelBag)
                case .failure: ()
                }
            }.store(in: cancelBag)
        expect(counter == 2).toEventually(beTrue(), timeout: .seconds(timeout))
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

    func cachedRequest(cachePolicy: Common.CachePolicy) -> AnyPublisher<
        NetworkAgentSampleNamespace.ResponseDto.EmployeeServiceAvailability,
        Never
    >? {
        let defaultForNetworkAgent: NetworkAgentSampleAPIProtocol = SimpleNetworkAgentSampleAPI(session: .defaultForNetworkAgent)
        //
        let serviceKey = #function
        let requestDto = NetworkAgentSampleNamespace.RequestDto.Employee(someParam: "aaa")
        let apiRequest = defaultForNetworkAgent.sampleRequestJSON(requestDto)
        let serviceParams: [any Hashable] = [requestDto.someParam]
        let apiResponseType = NetworkAgentSampleNamespace.ResponseDto.EmployeeServiceAvailability.self
        //
        return Common.GenericRequestWithCodableCache.perform(
            apiRequest,
            apiResponseType,
            cachePolicy,
            serviceKey,
            serviceParams,
            60 * 24 * 30, // 1 month
            codableCacheManager()
        ).eraseToAnyPublisher()

        /*
         let requestDto = NetworkAgentSampleNamespace.RequestDto.Employee(someParam: "aaa")
         return service.sampleRequestJSON(requestDto).errorToNever()

         let codableCacheManager = Common_SimpleCacheManagerForCodable.shared
         let defaultForNetworkAgent: NetworkAgentSampleAPIProtocol = SimpleNetworkAgentSampleAPI(session: .defaultForNetworkAgent)
         //
         let serviceKey = #function
         let requestDto = NetworkAgentSampleNamespace.RequestDto.Employee(someParam: "aaa")
         let apiRequest = defaultForNetworkAgent.sampleRequestJSON(requestDto)
         let serviceParams: [any Hashable] = [requestDto.someParam]
         let apiResponseType = NetworkAgentSampleNamespace.ResponseDto.EmployeeServiceAvailability.self
         //
         return Common.GenericRequestWithCodableCache.perform(
             apiRequest,
             apiResponseType,
             cachePolicy,
             serviceKey,
             serviceParams,
             60 * 24 * 30, // 1 month
             codableCacheManager
         ).eraseToAnyPublisher()
         */
    }
}
