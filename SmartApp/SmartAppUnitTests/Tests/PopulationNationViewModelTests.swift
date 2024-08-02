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

final class PopulationNationViewModelTests: XCTestCase {
    lazy var dataUSAServiceMock: DataUSAServiceProtocol = { DependenciesManager.Services.dataUSAServiceMock }()
    private var viewModel: PopulationNationViewModel?

    override func tearDown() {
        super.tearDown()
    }

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        loadedAny = nil
        cancelBag.cancel()
        if viewModel == nil {
            let dependencies: PopulationNationViewModel.Dependencies = .init(
                model: .init(), dataUSAService: dataUSAServiceMock
            )
            viewModel = await PopulationNationViewModel(dependencies: dependencies)
        }
    }
}

//
// MARK: - Tests
//

extension PopulationNationViewModelTests {
    // Test to check if the EditUserDetails view model loads successfully
    func testA1_testLoad() async throws {
        _ = await MainActor.run {
            expect(self.viewModel).notTo(beNil()) // Assert that the EditUserDetails view model is not nil
        }
    }

    @MainActor func testA1_updatingTitleAfterReceivingRecords() {
        guard let viewModel = viewModel else {
            return
        }
        // Initial title
        XCTAssert(viewModel.title == "PopulationNationViewTitle".localized)

        // Fetch records
        viewModel.send(action: .getPopulationData)

        // Record fetch delay
        let expectation = XCTestExpectation(description: "Request time")
        let timeout: Double = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout + 0.1)

        // Validate time change
        let expectedTitle = String(format: "PopulationNationViewTitleWithRecords".localized, viewModel.model.count)
        expect(viewModel.title == expectedTitle)
            .toEventually(beTrue(), timeout: .seconds(Int(timeout)))
    }
}
