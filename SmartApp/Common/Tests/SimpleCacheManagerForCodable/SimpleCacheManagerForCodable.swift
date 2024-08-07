import XCTest
import Foundation
import Combine
//
import Nimble

@testable import Common

struct MyStruct: Codable {
    let name: String
    let age: Int
    let height: Double

    static var random: MyStruct {
        let randomName = UUID().uuidString
        let randomAge = Int.random(in: 18...40)
        let randomHeight = Double.random(in: 150...200)
        return MyStruct(name: randomName, age: randomAge, height: randomHeight)
    }
}

final class SimpleCacheManagerForCodable_Tests: XCTestCase {
    var enabled: Bool = true
    private var service: NetworkAgentSampleAPIProtocol {
        SimpleNetworkAgentSampleAPI(session: .defaultForNetworkAgent)
    }

    private var codableCacheManager: CodableCacheManagerProtocol {
        Common_SimpleCacheManagerForCodable.shared
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        loadedAny = nil
        cancelBag.cancel()
    }

    // Create a function to generate random values for the struct

    private func store(count: Int) {
        for i in 0...count {
            codableCacheManager.syncStore(
                MyStruct.random,
                key: "cachedKey_\(i)",
                params: [],
                timeToLiveMinutes: nil
            )
        }
    }

    private func auxiliar_fetchFirst() {
        if codableCacheManager.syncRetrieve(
            MyStruct.self,
            key: "cachedKey_0",
            params: []
        ) != nil {
        } else {
            XCTAssert(false)
        }
    }

    private func auxiliar_deleteAllRecords() {
        codableCacheManager.clearAll()
    }

    private func auxiliar_cachedRequest(cachePolicy: Common.CachePolicy) -> AnyPublisher<
        NetworkAgentSampleNamespace.ResponseDto.EmployeeServiceAvailability,
        Never
    >? {
        let requestDto = NetworkAgentSampleNamespace.RequestDto.Employee(someParam: "aaa")
        return service.sampleRequestJSON(requestDto).errorToNever()
    }

    func test_cachePolicy_ignoringCache() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        var counter = 0
        auxiliar_deleteAllRecords()
        auxiliar_cachedRequest(cachePolicy: .ignoringCache)?
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
        guard enabled else {
            XCTAssert(true)
            return
        }
        var counter = 0
        auxiliar_deleteAllRecords()
        auxiliar_cachedRequest(cachePolicy: .cacheElseLoad)?
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
        guard enabled else {
            XCTAssert(true)
            return
        }
        var counter = 0
        auxiliar_deleteAllRecords()
        auxiliar_cachedRequest(cachePolicy: .cacheDontLoad)?
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
        guard enabled else {
            XCTAssert(true)
            return
        }
        var counter = 0
        auxiliar_deleteAllRecords()
        auxiliar_cachedRequest(cachePolicy: .cacheAndLoad)?
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
        guard enabled else {
            XCTAssert(true)
            return
        }
        var counter = 0
        auxiliar_deleteAllRecords()
        auxiliar_cachedRequest(cachePolicy: .ignoringCache)?
            .sinkToReceiveValue { some in
                switch some {
                case .success:
                    self.auxiliar_cachedRequest(cachePolicy: .cacheAndLoad)?
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
        guard enabled else {
            XCTAssert(true)
            return
        }
        auxiliar_deleteAllRecords()
        store(count: 10000)
        measure {
            auxiliar_fetchFirst()
        }
    }
}
