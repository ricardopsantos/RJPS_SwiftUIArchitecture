import XCTest
import Foundation
import Combine
//
import Nimble

@testable import Common
class CommonCoreData_Tests: XCTestCase {
    func enabled() -> Bool {
        true
    }
    
    var bd: CommonCoreData.Utils.Sample.CRUDEntityDBRepository {
        CommonCoreData.Utils.Sample.CRUDEntityDBRepository.shared
    }
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        TestsGlobal.loadedAny = nil
        TestsGlobal.cancelBag.cancel()
    }
    
    func test_syncCRUD() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        bd.syncClearAll()
        XCTAssert(bd.syncRecordCount() == 0)
        
        let toStore: CommonCoreData.Utils.Sample.CRUDEntity = .random
        bd.syncStore(toStore)
        XCTAssert(bd.syncRecordCount() == 1)
        XCTAssert(bd.syncRecordCount() == bd.syncAllIds().count)

        let stored = bd.syncRetrieve(key: toStore.id)
        XCTAssert(stored == toStore)
    }
    
    func test_aSyncCRUD() async {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        await bd.aSyncClearAll()
        let count1 = await bd.aSyncRecordCount()
        let count2 = await bd.aSyncAllIds().count
        XCTAssert(count1 == 0)
        XCTAssert(count1 == count2)

        let toStore: CommonCoreData.Utils.Sample.CRUDEntity = .random
        await bd.aSyncStore(toStore)
        
        let count3 = await bd.aSyncRecordCount()
        XCTAssert(count3 == 1)

        let stored = await bd.aSyncRetrieve(key: toStore.id)
        XCTAssert(stored == toStore)
    }
    
    func test_performance_syncCRUD() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        for i in 0...100 {
            bd.aSyncStore(toStore)
        }
        measure {
            // Time: 0.004 sec
            syncFetchFirst()
        }
    }
}
