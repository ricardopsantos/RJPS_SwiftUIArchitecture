//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

/// @testable import comes from the ´PRODUCT_NAME´ on __.xcconfig__ file

@testable import Smart_Dev

import XCTest
import Combine
import Nimble
//
import Domain
import Core
import Common

final class CodableCacheManagerProtocolTests: XCTestCase {
    var enabled: Bool = true
    private let userDefaultsRepository = Common.CacheManagerForCodableUserDefaultsRepository.shared
    private let coreDataRepository = Common.CacheManagerForCodableCoreDataRepository.shared

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        loadedAny = nil
        cancelBag.cancel()
    }
}

//
// MARK: - Tests
//

extension CodableCacheManagerProtocolTests {
    func testA_testSyncCacheManageCRUD() {
        testSyncCacheManageCRUD(cacheManager: userDefaultsRepository)
        testSyncCacheManageCRUD(cacheManager: coreDataRepository)
    }

    func testB_testAsyncCacheManageCRUD() async {
        await testAsyncCacheManageCRUD(cacheManager: userDefaultsRepository)
        await testAsyncCacheManageCRUD(cacheManager: coreDataRepository)
    }

    func testC_userDefaultsRepositoryWritePerformance() {
        let expectedTime = 0.6
        let repository = userDefaultsRepository
        let count = 1000
        measure {
            repository.syncClearAll()
            let expectation = expectation(description: #function)
            for i in 1...count {
                repository.syncStore(
                    ModelDto.GetWeatherResponse.mockBigLoad,
                    key: "key_\(i)",
                    params: [],
                    timeToLiveMinutes: nil
                )
            }
            expectation.fulfill()
            wait(for: [expectation], timeout: expectedTime * 1.25 * Double(count))
        }
        XCTAssert(repository.syncAllCachedKeys().count == count)
    }

    func testD_coreDataRepositoryWritePerformance() {
        let expectedTime = 1.6
        let repository = coreDataRepository
        let count = 1000
        measure {
            repository.syncClearAll()
            let expectation = expectation(description: #function)
            for i in 1...count {
                repository.syncStore(
                    ModelDto.GetWeatherResponse.mockBigLoad,
                    key: "key_\(i)",
                    params: [],
                    timeToLiveMinutes: nil
                )
            }
            expectation.fulfill()
            wait(for: [expectation], timeout: expectedTime * 1.25 * Double(count))
        }
        XCTAssert(repository.syncAllCachedKeys().count == count)
    }
}

extension CodableCacheManagerProtocolTests {
    func testSyncCacheManageCRUD(cacheManager: CodableCacheManagerProtocol) {
        let key = String.random(50)

        let toStore = ModelDto.GetWeatherResponse.mockBigLoad
        cacheManager.syncClearAll()

        XCTAssert(cacheManager.syncAllCachedKeys().isEmpty)

        cacheManager.syncStore(toStore, key: key, params: [], timeToLiveMinutes: nil)

        XCTAssert(cacheManager.syncAllCachedKeys().count == 1)

        if let record = cacheManager.syncRetrieve(
            ModelDto.GetWeatherResponse.self,
            key: key,
            params: []
        ) {
            XCTAssert(record.model == toStore)
        } else {
            XCTAssert(false)
        }

        cacheManager.syncClearAll()

        if cacheManager.syncRetrieve(
            ModelDto.GetWeatherResponse.self,
            key: key,
            params: []
        ) != nil {
            XCTAssert(false)
        } else {
            XCTAssert(true)
        }

        XCTAssert(cacheManager.syncAllCachedKeys().isEmpty)
    }

    func testAsyncCacheManageCRUD(cacheManager: CodableCacheManagerProtocol) async {
        let key = String.random(50)
        let toStore = ModelDto.GetWeatherResponse.mockBigLoad
        await cacheManager.aSyncClearAll()

        let recordCount1 = await cacheManager.aSyncAllCachedKeys().count
        XCTAssert(recordCount1 == 0)

        await cacheManager.aSyncStore(toStore, key: key, params: [], timeToLiveMinutes: nil)

        let recordCount2 = await cacheManager.aSyncAllCachedKeys().count
        XCTAssert(recordCount2 == 1)

        await cacheManager.aSyncStore(toStore, key: key, params: [], timeToLiveMinutes: nil)

        if let record = await cacheManager.aSyncRetrieve(
            ModelDto.GetWeatherResponse.self,
            key: key,
            params: []
        ) {
            XCTAssert(record.model == toStore)
        } else {
            XCTAssert(false)
        }

        await cacheManager.aSyncClearAll()

        if await cacheManager.aSyncRetrieve(
            ModelDto.GetWeatherResponse.self,
            key: key,
            params: []
        ) != nil {
            XCTAssert(false)
        } else {
            XCTAssert(true)
        }

        let recordCount3 = await cacheManager.aSyncAllCachedKeys().count
        XCTAssert(recordCount3 == 0)
    }
}
