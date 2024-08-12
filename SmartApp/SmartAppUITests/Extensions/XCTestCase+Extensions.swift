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

//
// MARK: - Misc
//
public extension XCTestCase {
    static var timeout: Double = 3

    func describe(app: XCUIApplication) {
        let secureTextFields = app.secureTextFields.allElementsBoundByIndex
            .map { $0.describe(false) }
        let textFields = app.textFields.allElementsBoundByIndex
            .map { $0.describe(false) }
        let staticTexts = app.staticTexts.allElementsBoundByIndex
            .map { $0.describe(false) }
        let buttons = app.buttons.allElementsBoundByIndex
            .map { $0.describe(false) }
        var result = "\n"
        if !secureTextFields.isEmpty {
            result += "# secureTextFields[\(secureTextFields.count)]: \(secureTextFields)" + "\n"
        }
        if !textFields.isEmpty {
            result += "# textFields[\(textFields.count)]: \(textFields)" + "\n"
        }
        if !staticTexts.isEmpty {
            result += "# staticTexts[\(staticTexts.count)]: \(staticTexts)" + "\n"
        }
        if !buttons.isEmpty {
            result += "# buttons[\(buttons.count)]: \(buttons)" + "\n"
        }
        Common_Logs.debug(result)
    }
}
