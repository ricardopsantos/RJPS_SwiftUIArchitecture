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

final class WeatherServiceTests: XCTestCase {
    var enabled: Bool = true

    lazy var service: WeatherServiceProtocol = { DependenciesManager.Services.weatherService }()

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

extension WeatherServiceTests {
    // Test to verify that weather information can be fetched by coordinates
    func testA1_weatherService_getWeather() async {
        // Check if the test is enabled before proceeding
        guard enabled else {
            XCTAssert(true) // Test is enabled, so we can return true and skip the test
            return
        }

        do {
            // Attempt to fetch weather data using the provided coordinates
            loadedAny = try await service.getWeather(.init(
                latitude: "38.736946",
                longitude: "-9.142685"
            ), cachePolicy: .load)

            // Verify that the weather data was successfully loaded
            XCTAssertTrue(loadedAny != nil, "Weather data should be loaded successfully.")
        } catch {
            // In case of an error, fail the test
            XCTAssertTrue(false, "Failed to fetch weather data with error: \(error)")
        }
    }
}

//
// MARK: - Performance Tests
//

extension WeatherServiceTests {
    func test_requestPopulationStateData_Performance_Load() throws {
        let cachePolicy: ServiceCachePolicy = .load
        let expectedTime: Double = 0.70
        let count = 10
        // Time: 0.708 sec
        measure {
            let expectation = self.expectation(description: #function)
            Task {
                do {
                    for _ in 1...count {
                        _ = try await service.getWeather(.init(
                            latitude: "38.736946",
                            longitude: "-9.142685"
                        ), cachePolicy: cachePolicy)
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
        let expectedTime: Double = 0.006
        let count = 10
        // Time: 0.006 sec
        measure {
            let expectation = self.expectation(description: #function)
            Task {
                do {
                    for _ in 1...count {
                        _ = try await service.getWeather(.init(
                            latitude: "38.736946",
                            longitude: "-9.142685"
                        ), cachePolicy: cachePolicy)
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
