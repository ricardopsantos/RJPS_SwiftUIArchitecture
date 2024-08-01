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

public extension NSPredicate {
    static var exists: NSPredicate {
        NSPredicate(format: "exists == true")
    }
}

public extension XCUIElement {
    var attributes: String? {
        /// "Attributes: TextField, 0x12b6b6e20, {{97.7, 68.7}, {276.3, 17.0}}, placeholderValue: \'Username\', value: Username, Keyboard Focused"
        let debugDescription = debugDescription.split(by: "\n")
        return debugDescription.filter { $0.hasPrefix("Attributes:") }.first
    }

    var keyboardFocused: Bool? {
        attributes?.contains("Keyboard Focused")
    }

    func describe(_ full: Bool) -> String {
        var description = ""

        if !label.isEmpty {
            description = "{\(description)label:\(label)"
        } else {
            description = "{\(description)label:n/a"
        }
        if !identifier.isEmpty {
            description = "\(description), id:\(identifier)"
        }
        if "\(String(describing: value))" != "Optional()" {
            description = "\(description), value:\(String(describing: value))"
        }
        if !title.isEmpty {
            description = "\(description), title:\(title)"
        }
        if full {
            if elementType.rawValue == 48 {
                description = "\(description), type:text"
            } else if elementType.rawValue == 9 {
                description = "\(description), type:button"
            } else {
                description = "\(description), type:\(elementType.rawValue)"
            }
            description = "\(description), \(frame)"
        }
        description = "\(description)}"
        return description
    }
}

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
        Common.LogsManager.debug(result)
    }
}

//
// MARK: - waitFor
//

public extension XCTestCase {
    func wait(delay: Double) {
        guard delay > 0 else {
            return
        }
        let expectation = expectation(description: "Wait \(delay)...")
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: delay + 0.1)
    }

    func waitFor<T>(
        object: T,
        timeout: TimeInterval = XCTestCase.timeout,
        file: String = #file,
        line: Int = #line,
        expectationPredicate: @escaping (T) -> Bool
    ) {
        let predicate = NSPredicate { obj, _ in expectationPredicate(obj as! T) }
        expectation(for: predicate, evaluatedWith: object, handler: nil)
        waitForExpectations(timeout: timeout) { [self] error in
            if error != nil {
                let message = "Failed to fulfil expectation block for \(object) after \(timeout) seconds."
                let location = XCTSourceCodeLocation(filePath: file, lineNumber: line)
                let issue = XCTIssue(
                    type: .assertionFailure,
                    compactDescription: message,
                    detailedDescription: nil,
                    sourceCodeContext: .init(location: location),
                    associatedError: nil,
                    attachments: []
                )
                record(issue)
            }
        }
    }

    func waitFor(
        textField: String,
        on app: XCUIApplication,
        timeout: TimeInterval = XCTestCase.timeout
    ) {
        let expectation = expectation(
            for: NSPredicate.exists,
            evaluatedWith: app.textFields[textField],
            handler: nil
        )
        wait(for: [expectation], timeout: timeout)
    }

    func waitFor(
        staticText: String,
        on app: XCUIApplication,
        timeout: TimeInterval = XCTestCase.timeout
    ) {
        let expectation = expectation(
            for: NSPredicate.exists,
            evaluatedWith: app.staticTexts[staticText],
            handler: nil
        )
        wait(for: [expectation], timeout: timeout)
    }

    func waitFor(
        buttonWithText: String,
        on app: XCUIApplication,
        timeout: TimeInterval = XCTestCase.timeout
    ) {
        let expectation = expectation(
            for: NSPredicate.exists,
            evaluatedWith: app.buttons[buttonWithText],
            handler: nil
        )
        wait(for: [expectation], timeout: timeout)
    }
}

//
// MARK: - Exists
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

//
// MARK: - Tap
//

public extension XCTestCase {
    
    func tap(
        tabBarIndex: Int,
        andWaitForStaticText nextStaticText: String = "",
        on app: XCUIApplication,
        timeout: TimeInterval = XCTestCase.timeout
    ) {
        let tabBarId = "Tab Bar"
        let expectation = expectation(
            for: NSPredicate.exists,
            evaluatedWith: app.tabBars[tabBarId],
            handler: nil
        )
        wait(for: [expectation], timeout: timeout)
        app.tabBars[tabBarId].buttons.element(boundBy: tabBarIndex).tap()
        if !nextStaticText.isEmpty {
            waitFor(staticText: nextStaticText, on: app, timeout: timeout)
        }
    }
    
    func tap(
        tabBarText: String,
        andWaitForStaticText nextStaticText: String = "",
        on app: XCUIApplication,
        timeout: TimeInterval = XCTestCase.timeout
    ) {
        let tabBarId = "Tab Bar"
        let expectation = expectation(
            for: NSPredicate.exists,
            evaluatedWith: app.tabBars[tabBarId],
            handler: nil
        )
        wait(for: [expectation], timeout: timeout)
        app.tabBars[tabBarId].buttons[tabBarText].tap()
        if !nextStaticText.isEmpty {
            waitFor(staticText: nextStaticText, on: app, timeout: timeout)
        }
    }
    
    func tap(
        button: String,
        andWaitForStaticText nextStaticText: String = "",
        andWaitForButtonWithText nextButtonWithText: String = "",
        on app: XCUIApplication,
        timeout: TimeInterval = XCTestCase.timeout
    ) {
        let expectation = expectation(
            for: NSPredicate.exists,
            evaluatedWith: app.buttons[button],
            handler: nil
        )
        wait(for: [expectation], timeout: timeout)
        app.buttons[button].tap()
        if !nextStaticText.isEmpty {
            waitFor(staticText: nextStaticText, on: app, timeout: timeout)
        }
        if !nextButtonWithText.isEmpty {
            waitFor(buttonWithText: nextButtonWithText, on: app)
        }
    }

    func tap(
        secureTextField: String,
        andType text: String,
        dismissKeyboard: Bool,
        on app: XCUIApplication,
        delayBeforeTap: Double = 0.0,
        delayBeforeType: Double = 0.0
    ) {
        wait(delay: delayBeforeTap)
        let secureTextField = app.secureTextFields[secureTextField]
        secureTextField.tap()
        if let textFieldValue = secureTextField.value as? String, !textFieldValue.isEmpty {
            secureTextField.tap()
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: textFieldValue.count)
            wait(delay: delayBeforeType)
            secureTextField.typeText(deleteString + text)
        } else {
            secureTextField.typeText(text)
        }
        if dismissKeyboard {
            tap(
                // button: XCUIKeyboardKey.enter.rawValue,
                button: "retorno",
                on: app
            )
        }
    }

    func tap(
        textFieldXCUIElement: XCUIElement,
        andType text: String,
        dismissKeyboard: Bool,
        on app: XCUIApplication,
        delayBeforeType: Double = 0.0
    ) {
        textFieldXCUIElement.tap()
        if let textFieldValue = textFieldXCUIElement.value as? String, !textFieldValue.isEmpty {
            textFieldXCUIElement.tap()
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: textFieldValue.count)
            wait(delay: delayBeforeType)
            textFieldXCUIElement.typeText(deleteString + text)
        } else {
            wait(delay: delayBeforeType)
            textFieldXCUIElement.typeText(text)
        }
        if dismissKeyboard {
            tap(
                // button: XCUIKeyboardKey.return.rawValue,
                button: "retorno",
                on: app
            )
        }
    }

    func tap(
        textFieldIndex: Int,
        andType text: String,
        dismissKeyboard: Bool,
        on app: XCUIApplication,
        delayBeforeTap: Double = 0.0,
        delayBeforeType: Double = 0.0
    ) {
        wait(delay: delayBeforeTap)
        if app.textFields.count - 1 >= textFieldIndex {
            let textField = app.textFields.element(boundBy: textFieldIndex)
            tap(
                textFieldXCUIElement: textField,
                andType: text,
                dismissKeyboard: dismissKeyboard,
                on: app,
                delayBeforeType: delayBeforeType
            )
        }
    }

    func tap(
        textField: String,
        andType text: String,
        dismissKeyboard: Bool,
        on app: XCUIApplication,
        delayBeforeTap: Double = 0.0,
        delayBeforeType: Double = 0.0
    ) {
        wait(delay: delayBeforeTap)
        let textField = app.textFields[textField]
        tap(
            textFieldXCUIElement: textField,
            andType: text,
            dismissKeyboard: dismissKeyboard,
            on: app,
            delayBeforeType: delayBeforeType
        )
    }

    func tap(
        staticText: String,
        andWaitForStaticText nextStaticText: String = "",
        on app: XCUIApplication,
        timeout: TimeInterval = XCTestCase.timeout
    ) {
        let expectation = expectation(
            for: NSPredicate.exists,
            evaluatedWith: app.staticTexts[staticText],
            handler: nil
        )
        wait(for: [expectation], timeout: timeout)
        app.staticTexts[staticText].tap()
        if !nextStaticText.isEmpty {
            waitFor(staticText: nextStaticText, on: app, timeout: timeout)
        }
    }

    func tap(
        alert title: String,
        option: String,
        andWaitForStaticText nextStaticText: String = "",
        on app: XCUIApplication,
        timeout: TimeInterval = XCTestCase.timeout
    ) {
        waitFor(staticText: title, on: app)

        let expectation = expectation(
            for: NSPredicate.exists,
            evaluatedWith: app.alerts.element.buttons[option],
            handler: nil
        )
        wait(for: [expectation], timeout: timeout)
        app.alerts.element.buttons[option].tap()
        if !nextStaticText.isEmpty {
            waitFor(staticText: nextStaticText, on: app, timeout: timeout)
        }
    }
}
