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

final class DataBaseRepository_Tests: XCTestCase {
    var enabled: Bool = true
    private var repository: DataBaseRepositoryProtocol? = DependenciesManager.Repository.dataBaseRepository

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        loadedAny = nil
        cancelBag.cancel()
    }
}

//
// MARK: - Auxiliar
//

extension DataBaseRepository_Tests {
    @discardableResult
    func saveRandomEntity(events: Int = 0) -> String {
        let cascadeEvents: [Model.TrackedLog] = (1...events).map { _ in Model.TrackedLog.random }
        let trackedEntity: Model.TrackedEntity = .random(cascadeEvents: cascadeEvents)
        return repository?.trackedEntityInsert(trackedEntity: trackedEntity) ?? ""
    }
}

//
// MARK: - Tests
//

extension DataBaseRepository_Tests {
    func test_trackedEntityDeleteAll() {
        repository?.trackedEntityDeleteAll()
        XCTAssertEqual(repository?.trackedEntityGetAll(favorite: nil, archived: nil, cascade: false).count ?? 0, 0)
        XCTAssertEqual(repository?.trackedLogGetAll(cascade: false).count ?? 0, 0)

        // Save 2 entities
        saveRandomEntity(events: 10)
        saveRandomEntity(events: 10)

        // Should have 2 entities and 20 events
        XCTAssertEqual(repository?.trackedEntityGetAll(favorite: nil, archived: nil, cascade: false).count ?? 0, 2)
        XCTAssertEqual(repository?.trackedLogGetAll(cascade: false).count ?? 0, 20)

        // Delete all
        repository?.trackedEntityDeleteAll()

        // Should have 0 entities and 0 events
        XCTAssertEqual(repository?.trackedEntityGetAll(favorite: nil, archived: nil, cascade: false).count ?? 0, 0)
        XCTAssertEqual(repository?.trackedLogGetAll(cascade: false).count ?? 0, 0)
    }

    func test_trackedEntitySaveAndRetrieved() {
        repository?.trackedEntityDeleteAll()
        XCTAssertEqual(repository?.trackedEntityGetAll(favorite: nil, archived: nil, cascade: false).count ?? 0, 0)
        XCTAssertEqual(repository?.trackedLogGetAll(cascade: false).count ?? 0, 0)

        let before = repository?.trackedEntityGetAll(favorite: nil, archived: nil, cascade: false).count ?? 0
        let trackedEntityId = saveRandomEntity(events: 3)
        let retrieved = repository?.trackedEntityGet(trackedEntityId: trackedEntityId, cascade: true)
        let after = repository?.trackedEntityGetAll(favorite: nil, archived: nil, cascade: false).count ?? 0

        // Should have same id, one more event, and same cascade event count
        XCTAssert(retrieved?.id == trackedEntityId)
        XCTAssert(before + 1 == after)
        XCTAssert(retrieved?.cascadeEvents?.count ?? 0 == 3)
    }

    func test_trackedEntitySaveAndRetrievedAndUpdate() {
        repository?.trackedEntityDeleteAll()
        XCTAssertEqual(repository?.trackedEntityGetAll(favorite: nil, archived: nil, cascade: false).count ?? 0, 0)
        XCTAssertEqual(repository?.trackedLogGetAll(cascade: false).count ?? 0, 0)

        var logsCount: Int = 0

        // Create 1 event with 3 logs
        let trackedEntityId = saveRandomEntity(events: 3)
        guard var trackedEntity = repository?.trackedEntityGet(
            trackedEntityId: trackedEntityId,
            cascade: true) else {
            XCTAssert(false)
            return
        }

        // We should be able to fetch the event
        guard let first = trackedEntity.cascadeEvents?.first else {
            XCTAssert(false)
            return
        }

        // Update the event, and keep one log only, and save...
        trackedEntity.cascadeEvents = [first]
        repository?.trackedEntityUpdate(trackedEntity: trackedEntity)

        // We should be able to fetch the event
        guard repository?.trackedEntityGet(
            trackedEntityId: trackedEntityId,
            cascade: true) != nil else {
            XCTAssert(false)
            return
        }

        // We should have only 1 log assoc to the event
        logsCount = repository?.trackedLogGet(trackedEntityId: trackedEntityId, cascade: false).count ?? 0
        XCTAssertEqual(logsCount, 1)

        // Delete all logs and save
        guard var trackedEntity = repository?.trackedEntityGet(
            trackedEntityId: trackedEntityId,
            cascade: true) else {
            XCTAssert(false)
            return
        }
        trackedEntity.cascadeEvents = []
        repository?.trackedEntityUpdate(trackedEntity: trackedEntity)

        // Should have no associated events
        logsCount = repository?.trackedLogGet(trackedEntityId: trackedEntityId, cascade: false).count ?? 0
        XCTAssertEqual(logsCount, 0)

        logsCount = repository?.trackedLogGetAll(cascade: false).count ?? 0
        XCTAssertEqual(logsCount, 0)
    }
}
