import XCTest
import Foundation
import Combine
//
import Nimble

@testable import Common
class CommonCoreData_Tests: XCTestCase {
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
}

//
// MARK: - CRUD
//
extension CommonCoreData_Tests {
    func test_syncCRUD() {
        guard enabled() else {
            XCTAssert(true)
            return
        }

        // Records count
        bd.syncClearAll()
        XCTAssert(bd.syncRecordCount() == 0)

        // Insert
        var toStore: CommonCoreData.Utils.Sample.CRUDEntity = .random
        bd.syncStore(toStore)
        XCTAssert(bd.syncRecordCount() == 1)
        XCTAssert(bd.syncRecordCount() == bd.syncAllIds().count)

        // Get
        var stored = bd.syncRetrieve(key: toStore.id)
        XCTAssert(stored == toStore)

        // Update
        toStore.name = "NewName"
        bd.syncUpdate(toStore)

        stored = bd.syncRetrieve(key: toStore.id)
        XCTAssert(stored?.name == "NewName")

        // Delete
        if let stored = stored {
            bd.syncDelete(stored)
            let some = bd.syncRetrieve(key: toStore.id)
            XCTAssert(some == nil)
            let count1 = bd.syncRecordCount()
            let count2 = bd.syncAllIds().count
            XCTAssert(count1 == 0)
            XCTAssert(count1 == count2)
        } else {
            XCTAssert(false)
        }
    }

    func test_aSyncCRUD() async {
        guard enabled() else {
            XCTAssert(true)
            return
        }

        // Records count
        await bd.aSyncClearAll()
        let count1 = await bd.aSyncRecordCount()
        let count2 = await bd.aSyncAllIds().count
        XCTAssert(count1 == 0)
        XCTAssert(count1 == count2)

        // Insert
        var toStore: CommonCoreData.Utils.Sample.CRUDEntity = .random
        await bd.aSyncStore(toStore)

        // Records count
        let count3 = await bd.aSyncRecordCount()
        XCTAssert(count3 == 1)

        // Get
        var stored = await bd.aSyncRetrieve(key: toStore.id)
        XCTAssert(stored == toStore)

        // Update
        toStore.name = "NewName"
        await bd.aSyncUpdate(toStore)

        stored = await bd.aSyncRetrieve(key: toStore.id)
        XCTAssert(stored?.name == "NewName")

        // Delete
        if let stored = stored {
            await bd.aSyncDelete(stored)
            let some = await bd.aSyncRetrieve(key: toStore.id)
            XCTAssert(some == nil)
            let count1 = await bd.aSyncRecordCount()
            let count2 = await bd.aSyncAllIds().count
            XCTAssert(count1 == 0)
            XCTAssert(count1 == count2)
        } else {
            XCTAssert(false)
        }
    }
}

//
// MARK: - OverLoad
//
extension CommonCoreData_Tests {
    func test_syncOverLoad() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        bd.syncClearAll()
        for _ in 1...stressLoadValue {
            bd.syncStore(.random)
        }
        let stored = bd.syncRecordCount()
        XCTAssert(stored == stressLoadValue)
    }

    func test_aSyncOverLoad() async {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        await bd.aSyncClearAll()
        for _ in 1...stressLoadValue {
            await bd.aSyncStore(.random)
        }
        let stored = await bd.aSyncRecordCount()
        XCTAssert(stored == stressLoadValue)
    }
}

//
// MARK: - Others
//
extension CommonCoreData_Tests {
    func test_mergeContext1() async {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        await bd.aSyncClearAll()
        // save async
        await bd.aSyncStore(.random)
        // get sync
        let stored = await bd.aSyncRecordCount()
        XCTAssert(stored == 1)
    }

    func test_mergeContext2() async {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        bd.syncClearAll()
        // save sync
        bd.syncStore(.random)
        // get sync
        let stored = await bd.aSyncRecordCount()
        XCTAssert(stored == 1)
    }

    func test_emitEventOnDataBaseInsert_test1() {
        var didInsertedContent = (value: false, id: "")
        var didChangedContent = 0
        var didFinishChangeContent = 0
        let toStore = CommonCoreData.Utils.Sample.CRUDEntity.random
        bd.output()
            .sink { event in
                switch event {
                case .generic(let genericEvent):
                    switch genericEvent {
                    case .databaseDidInsertedContentOn(_, id: let id):
                        didInsertedContent = (true, id ?? "")
                    case .databaseDidChangedContentItemOn:
                        didChangedContent += 1
                    case .databaseDidUpdatedContentOn: ()
                    case .databaseDidDeletedContentOn: ()
                    case .databaseDidFinishChangeContentItemsOn:
                        didFinishChangeContent += 1
                    }
                }
            }.store(in: TestsGlobal.cancelBag)

        Common_Utils.delay { [weak self] in
            self?.bd.syncStore(toStore)
        }

        // Verify that the event is emitted
        expect(didFinishChangeContent == 1).toEventually(
            beTrue(),
            timeout: .seconds(TestsGlobal.timeout)
        )
        expect(didInsertedContent.value).toEventually(
            beTrue(),
            timeout: .seconds(TestsGlobal.timeout)
        )
        expect(didInsertedContent.id == toStore.id).toEventually(
            beTrue(),
            timeout: .seconds(TestsGlobal.timeout)
        )
        expect(didChangedContent == 1).toEventually(
            beTrue(),
            timeout: .seconds(TestsGlobal.timeout)
        )
    }

    func test_emitEventOnDataBaseInsert_test2() {
        var didInsertedContent = 0
        var didChangedContent = 0
        var didFinishChangeContent = 0
        let numberOfInserts = 3
        bd.output()
            .sink { event in
                switch event {
                case .generic(let genericEvent):
                    switch genericEvent {
                    case .databaseDidInsertedContentOn:
                        didInsertedContent += 1
                    case .databaseDidChangedContentItemOn:
                        didChangedContent += 1
                    case .databaseDidUpdatedContentOn: ()
                    case .databaseDidDeletedContentOn: ()
                    case .databaseDidFinishChangeContentItemsOn:
                        didFinishChangeContent += 1
                    }
                }
            }.store(in: TestsGlobal.cancelBag)

        Common_Utils.delay { [weak self] in
            for _ in 1...numberOfInserts {
                self?.bd.syncStore(.random)
            }
        }

        // Verify that the event is emitted
        expect(didInsertedContent == didInsertedContent).toEventually(
            beTrue(),
            timeout: .seconds(TestsGlobal.timeout)
        )
        expect(didChangedContent == numberOfInserts).toEventually(
            beTrue(),
            timeout: .seconds(TestsGlobal.timeout)
        )
        expect(didFinishChangeContent == numberOfInserts).toEventually(
            beTrue(),
            timeout: .seconds(TestsGlobal.timeout)
        )
    }
}
