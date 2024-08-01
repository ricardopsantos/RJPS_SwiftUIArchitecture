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
import Common
import Domain
import Core

final class ___Template___ViewModelTests: BaseViewModelsTests {
    private var templateViewModel: ___Template___ViewModel?

    override func tearDown() {
        super.tearDown()
    }

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        loadedAny = nil
        cancelBag.cancel()

        if templateViewModel == nil {
            templateViewModel = await ___Template___ViewModel(dependencies: .init(model: .init(), onCompletion: { _ in
            }, sampleService: sampleService))
        }
    }
}

//
// MARK: - Template View Model
//

extension ___Template___ViewModelTests {
    // Test to check if the template view model loads successfully

    func testA1_testLoad() async throws {
        _ = await MainActor.run {
            expect(self.templateViewModel).notTo(beNil()) // Assert that the template view model is not nil
        }
    }

    // Test to verify the increment action in the template view model
    @MainActor func testA2_incrementAction() {
        // Assert initial counter value is 0
        expect(self.templateViewModel?.counter == 0).toEventually(beTrue(), timeout: .seconds(timeout))

        // Send increment action
        templateViewModel?.send(.increment)

        // Assert counter value is incremented to 1
        expect(self.templateViewModel?.counter == 1).toEventually(beTrue(), timeout: .seconds(timeout))

        // Assert message reflects the incremented counter value
        expect(self.templateViewModel?.message == "Counter: 1").toEventually(beTrue(), timeout: .seconds(timeout))
    }
}
