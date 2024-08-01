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

final class CoreServicesTests: XCTestCase {
    var enabled: Bool = true
    private var weatherService: WeatherServiceProtocol? = WeatherService.shared

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        loadedAny = nil
        cancelBag.cancel()
    }
}

//
// MARK: - Weather Service Tests
//

extension CoreServicesTests {
    // Test to verify that weather information can be fetched by coordinates
    func testA1_weatherService_getWeather() async {
        // Check if the test is enabled before proceeding
        guard enabled else {
            XCTAssert(true) // Test is enabled, so we can return true and skip the test
            return
        }

        do {
            // Define the coordinates for the test
            let latitude = "38.736946" // Latitude for the test location
            let longitude = "-9.142685" // Longitude for the test location

            // Attempt to fetch weather data using the provided coordinates
            loadedAny = try await weatherService?.getWeather(.init(
                latitude: latitude,
                longitude: longitude
            ))

            // Verify that the weather data was successfully loaded
            XCTAssertTrue(loadedAny != nil, "Weather data should be loaded successfully.")
        } catch {
            // In case of an error, fail the test
            XCTAssertTrue(false, "Failed to fetch weather data with error: \(error)")
        }
    }
}
