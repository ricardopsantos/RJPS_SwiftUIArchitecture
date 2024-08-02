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
/*
final class LoginViewModelTests: BaseViewModelsTests {
    private var viewModel: LoginViewModel?

    override func tearDown() {
        super.tearDown()
    }

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        loadedAny = nil
        cancelBag.cancel()
        if viewModel == nil {
            let authenticationViewModel: AuthenticationViewModel
                = await .init(
                    secureAppPreferences: secureAppPreferences,
                    nonSecureAppPreferences: nonSecureAppPreferences,
                    userRepository: userRepository
                )
            viewModel = await LoginViewModel(dependencies: .init(
                model: .init(),
                authenticationViewModel: authenticationViewModel
            ))
        }
    }
}

//
// MARK: - Tests
//

extension LoginViewModelTests {
    // Test to check if the EditUserDetails view model loads successfully
    func testA1_testLoad() async throws {
        _ = await MainActor.run {
            expect(self.viewModel).notTo(beNil()) // Assert that the EditUserDetails view model is not nil
        }
    }

    @MainActor func testA1_invalidEmail() {
        guard let viewModel = viewModel else {
            return
        }
        XCTAssert(viewModel.email.isEmpty)
        let debounce = viewModel.formEvalDebounce + 0.1
        let expectation = XCTestExpectation(description: "Debouch because the email changing -> eval form have one")
        DispatchQueue.main.asyncAfter(deadline: .now() + debounce) {
            viewModel.email = String.random(10)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: debounce + 0.1)
        expect(viewModel.errorMessage.lowercased() == "Invalid Email".lowercased())
            .toEventually(beTrue(), timeout: .seconds(timeout))
    }

    @MainActor func testA2_validForm() {
        guard let viewModel = viewModel else {
            return
        }
        expect(!viewModel.canLogin).to(beTrue())
        viewModel.email = "mail@mail.com"
        viewModel.password = "123"
        expect(viewModel.canLogin).toEventually(beTrue(), timeout: .seconds(timeout))
    }

    @MainActor func test_invalidForm1() {
        guard let viewModel = viewModel else {
            return
        }
        viewModel.canLogin = true
        viewModel.email = "123"
        viewModel.password = "123"
        expect(viewModel.canLogin).toEventually(beFalse(), timeout: .seconds(timeout))
    }

    @MainActor func test_invalidForm2() {
        guard let viewModel = viewModel else {
            return
        }
        viewModel.canLogin = true
        viewModel.email = ""
        viewModel.password = ""
        expect(viewModel.canLogin).toEventually(beFalse(), timeout: .seconds(timeout))
    }
}
*/
