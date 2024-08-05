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

final class EditUserDetailsViewModelTests: BaseViewModelsTests {
    let user1: Model.User = .init(
        name: "Ricardo",
        email: "mail@gmail.com",
        password: "password",
        dateOfBirth: .now,
        gender: Gender.other.rawValue,
        country: "PT"
    )

    private var viewModel: EditUserDetailsViewModel?

    override func tearDown() {
        super.tearDown()
    }

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        loadedAny = nil
        cancelBag.cancel()
        if viewModel == nil {
            viewModel = await EditUserDetailsViewModel(dependencies: .init(
                model: .init(),
                userRepository: userRepository,
                onUserSaved: {}
            ))
        }
    }
}

//
// MARK: - Tests
//

extension EditUserDetailsViewModelTests {
    // Test to check if the EditUserDetails view model loads successfully
    func testA1_testLoad() async throws {
        _ = await MainActor.run {
            expect(self.viewModel).notTo(beNil()) // Assert that the EditUserDetails view model is not nil
        }
    }

    // Test to verify user changes in the EditUserDetails view model
    @MainActor func testA2_userChanged() {
        var emittedEvent = false
        let randomName = String.randomWithSpaces(10) // Generate a random name

        // Subscribe to userChanged events from the userRepository
        userRepository.output([.userChanged])
            .sink { _ in
                emittedEvent = true
                self.viewModel?.send(action: .loadUserInfo) // Load user info after receiving the event
                // Test if the name matches the randomly generated name
                expect(self.viewModel?.name == randomName).toEventually(beTrue(), timeout: .seconds(timeout))
            }.store(in: cancelBag)

        // Send saveUser action to update the user details
        viewModel?.send(action: .saveUser(
            name: randomName,
            email: user1.email,
            dateOfBirth: user1.dateOfBirth ?? .now,
            gender: Gender(rawValue: user1.gender ?? "") ?? .other,
            country: user1.country ?? ""
        ))

        // Assert that the userChanged event is emitted when the user changes
        expect(emittedEvent).toEventually(beTrue(), timeout: .seconds(timeout))
    }
}
