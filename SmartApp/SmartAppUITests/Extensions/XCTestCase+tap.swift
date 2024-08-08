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
// MARK: - Tab Bar
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
}

//
// MARK: - Button
//
public extension XCTestCase {
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
}

//
// MARK: - TextField
//
public extension XCTestCase {
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
                button: "enter",
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
}

//
// MARK: - Static Text
//
public extension XCTestCase {
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
}

//
// MARK: - Alerts
//
public extension XCTestCase {
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
