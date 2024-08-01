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

final class ApplicationViewModelsTests: XCTestCase {
    lazy var sampleService: SampleServiceProtocol = { SampleService.shared }()
    lazy var secureAppPreferences: SecureAppPreferencesProtocol = { SecureAppPreferences.shared }()
    lazy var nonSecureAppPreferences: NonSecureAppPreferencesProtocol = { NonSecureAppPreferences.shared }()
    lazy var userRepository: UserRepositoryProtocol = { UserRepository(
        secureAppPreferences: secureAppPreferences,
        nonSecureAppPreferences: nonSecureAppPreferences
    ) }()

    let user1: Model.User = .init(
        name: "Ricardo",
        email: "mail@gmail.com",
        password: "password",
        dateOfBirth: .now,
        gender: Gender.other.rawValue,
        country: "PT"
    )

    private var editUserDetails: EditUserDetailsViewModel?
    private var templateViewModel: ___Template___ViewModel?

    override func tearDown() {
        super.tearDown()
    }

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        loadedAny = nil
        cancelBag.cancel()
        if editUserDetails == nil {
            editUserDetails = await EditUserDetailsViewModel(dependencies: .init(
                model: .init(),
                userRepository: userRepository,
                onUserSaved: {}
            ))
        }

        if templateViewModel == nil {
            templateViewModel = await ___Template___ViewModel(dependencies: .init(model: .init(), onCompletion: { _ in
            }, sampleService: sampleService))
        }
    }
}

//
// MARK: - Template View Model
//

extension ApplicationViewModelsTests {
    // Test to check if the template view model loads successfully

    func test_templateViewModel_testLoad() async throws {
        _ = await MainActor.run {
            expect(self.templateViewModel).notTo(beNil()) // Assert that the template view model is not nil
        }
    }

    // Test to verify the increment action in the template view model
    @MainActor func test_templateTest_incrementAction() {
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

//
// MARK: - Edit User Details
//

extension ApplicationViewModelsTests {
    // Test to check if the EditUserDetails view model loads successfully
    func test_editUserDetailsViewModel_testLoad() async throws {
        _ = await MainActor.run {
            expect(self.editUserDetails).notTo(beNil()) // Assert that the EditUserDetails view model is not nil
        }
    }

    // Test to verify user changes in the EditUserDetails view model
    @MainActor func test_editUserDetailsViewModel_testLoadUserChanged() {
        var emittedEvent = false
        let randomName = String.randomWithSpaces(10) // Generate a random name

        // Subscribe to userChanged events from the userRepository
        userRepository.output([.userChanged])
            .sink { _ in
                emittedEvent = true
                self.editUserDetails?.send(action: .loadUserInfo) // Load user info after receiving the event
                // Test if the name matches the randomly generated name
                expect(self.editUserDetails?.name == randomName).toEventually(beTrue(), timeout: .seconds(timeout))
            }.store(in: cancelBag)

        // Send saveUser action to update the user details
        editUserDetails?.send(action: .saveUser(
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
