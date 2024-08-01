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

class BaseViewModelsTests: XCTestCase {
    lazy var sampleService: SampleServiceProtocol = { SampleService.shared }()
    lazy var secureAppPreferences: SecureAppPreferencesProtocol = { SecureAppPreferences.shared }()
    lazy var nonSecureAppPreferences: NonSecureAppPreferencesProtocol = { NonSecureAppPreferences.shared }()
    lazy var userRepository: UserRepositoryProtocol = { UserRepository(
        secureAppPreferences: secureAppPreferences,
        nonSecureAppPreferences: nonSecureAppPreferences
    ) }()
}
