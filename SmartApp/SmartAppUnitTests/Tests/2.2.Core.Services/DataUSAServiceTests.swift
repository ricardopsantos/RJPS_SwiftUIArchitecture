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

final class DataUSAServiceTests: XCTestCase {
    lazy var service: DataUSAServiceProtocol = { DependenciesManager.Services.dataUSAService }()
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

extension DataUSAServiceTests {
    // Test to verify that PopulationStateDataResponse mock
    func test_mockPopulationStateData() async {
        XCTAssertTrue(ModelDto.PopulationStateDataResponse.mockRegularLoad != nil, "mock data should be loaded successfully.")
    }

    // Test to verify that PopulationStateData information can be fetched
    func test_requestPopulationStateData() async {
        do {
            // Attempt to fetch PopulationNationData
            loadedAny = try await service.requestPopulationStateData(.init(), cachePolicy: .load)

            // Verify that PopulationStateData was successfully loaded
            XCTAssertTrue(loadedAny != nil, "data should be loaded successfully.")
        } catch {
            // In case of an error, fail the test
            XCTAssertTrue(false, "Failed to fetch with error: \(error)")
        }
    }

    // Test to verify that PopulationNationDataResponse mock
    func test_mockPopulationNationDataResponse() async {
        XCTAssertTrue(ModelDto.PopulationNationDataResponse.mockRegularLoad != nil, "PopulationNationDataResponse.mock data should be loaded successfully.")
    }

    // Test to verify that PopulationNationDat information can be fetched
    func test_requestPopulationNationData() async {
        do {
            // Attempt to fetch PopulationNationData
            loadedAny = try await service.requestPopulationNationData(.init(), cachePolicy: .load)

            // Verify that PopulationNationData was successfully loaded
            XCTAssertTrue(loadedAny != nil, "PopulationNationData data should be loaded successfully.")
        } catch {
            // In case of an error, fail the test
            XCTAssertTrue(false, "Failed to fetch PopulationNationData with error: \(error)")
        }
    }
}

//
// MARK: - Performance Tests
//

extension DataUSAServiceTests {
    func test_requestPopulationStateData_Performance_Load() throws {
        let cachePolicy: ServiceCachePolicy = .load
        let expectedTime: Double = 0.498
        let count = 10
        // Time: 0.498 sec
        measure {
            let expectation = self.expectation(description: #function)
            Task {
                do {
                    for _ in 1...count {
                        _ = try await service.requestPopulationStateData(
                            .init(),
                            cachePolicy: cachePolicy
                        )
                    }
                    expectation.fulfill()
                } catch {
                    XCTFail("Async function threw an error: \(error)")
                }
            }
            wait(for: [expectation], timeout: expectedTime * 1.25 * Double(count))
        }
    }

    func test_requestPopulationStateData_Performance_CacheElseLoad() throws {
        let cachePolicy: ServiceCachePolicy = .cacheElseLoad
        let expectedTime: Double = 0.007
        let count = 10
        // Time: 0.007 sec
        measure {
            let expectation = self.expectation(description: #function)
            Task {
                do {
                    for _ in 1...count {
                        _ = try await service.requestPopulationStateData(
                            .init(),
                            cachePolicy: cachePolicy
                        )
                    }
                    expectation.fulfill()
                } catch {
                    XCTFail("Async function threw an error: \(error)")
                }
            }
            wait(for: [expectation], timeout: expectedTime * 1.25 * Double(count))
        }
    }
}
