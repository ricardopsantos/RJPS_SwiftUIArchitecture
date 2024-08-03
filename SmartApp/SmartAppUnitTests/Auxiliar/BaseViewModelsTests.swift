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

let cancelBag = CancelBag()
var timeout: Int = 5
var loadedAny: Any?

class BaseViewModelsTests: XCTestCase {
    lazy var sampleService: SampleServiceProtocol = { DependenciesManager.Services.sampleService }()
    lazy var secureAppPreferences: SecureAppPreferencesProtocol = { DependenciesManager.Repository.secureAppPreferences }()
    lazy var nonSecureAppPreferences: NonSecureAppPreferencesProtocol = { DependenciesManager.Repository.nonSecureAppPreferences }()
    lazy var userRepository: UserRepositoryProtocol = { UserRepository(
        secureAppPreferences: secureAppPreferences,
        nonSecureAppPreferences: nonSecureAppPreferences
    ) }()
}
