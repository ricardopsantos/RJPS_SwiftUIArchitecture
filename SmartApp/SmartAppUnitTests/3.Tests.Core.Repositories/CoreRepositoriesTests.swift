//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

/// @testable import comes from the ´PRODUCT_NAME´ on __.xcconfig__ file

@testable import Smart_Dev

//
import XCTest
import Combine
import Nimble
//
import Core

final class CoreRepositoriesTests: XCTestCase {
    var enabled: Bool = true
    private var nonSecureAppPreferences: NonSecureAppPreferencesProtocol? = DependenciesManager.Repository.nonSecureAppPreferences

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        loadedAny = nil
        cancelBag.cancel()
    }
}

//
// MARK: - Weather
//

extension CoreRepositoriesTests {
    // Test to verify that an event is emitted when a non-secure app preference property changes
    func test_nonSecureAppPreferences_emitEventOnChangedProperty() {
        var emittedEvent = false
        
        // Subscribe to output events for the .changedKey event with key .isAuthenticated
        nonSecureAppPreferences?.output([.changedKey(key: .isAuthenticated)])
            .sink { _ in
                emittedEvent = true // Set the flag to true when the event is received
            }.store(in: cancelBag)

        // Toggle the value of isAuthenticated to trigger the event
        if let isAuthenticated = nonSecureAppPreferences?.isAuthenticated {
            nonSecureAppPreferences?.isAuthenticated = !isAuthenticated
        }

        // Verify that the event is emitted
        expect(emittedEvent).toEventually(beTrue(), timeout: .seconds(timeout))
    }
}
