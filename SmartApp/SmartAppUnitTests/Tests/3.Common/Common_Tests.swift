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

final class Common_Tests: XCTestCase {
    var enabled: Bool = true
    private let cacheManagerV1 = Common.CacheManagerForCodableUserDefaultsRepository.shared
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

extension Common_Tests {


    func test_testSyncCacheManageCRUD() {
        //testSyncCacheManageCRUD(cacheManager: cacheManagerV1)
        testSyncCacheManageCRUD(cacheManager: coreDataRepository)
    }
    
    func test_testAsyncCacheManageCRUD() async {
        //await testAsyncCacheManageCRUD(cacheManager: cacheManagerV1)
         await testAsyncCacheManageCRUD(cacheManager: coreDataRepository)
    }
}

extension Common_Tests {
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
