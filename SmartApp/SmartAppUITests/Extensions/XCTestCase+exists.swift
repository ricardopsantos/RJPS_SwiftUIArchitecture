//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import XCTest
//
import Common

//
// https://www.appcoda.com/ui-testing-swiftui-xctest/
//

public extension XCTestCase {
    func exists(
        staticText: String,
        on app: XCUIApplication,
        timeout: TimeInterval = XCTestCase.timeout
    ) {
        XCTAssertTrue(app.staticTexts[staticText].waitForExistence(timeout: timeout))
    }
}
