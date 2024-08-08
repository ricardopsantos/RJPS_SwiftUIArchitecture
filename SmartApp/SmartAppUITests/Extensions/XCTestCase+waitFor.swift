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
// MARK: - wait(delay:)
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
}

//
// MARK: - waitFor(
//

public extension XCTestCase {
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
// MARK: - genericWaitFor
//

public extension XCTestCase {
    func genericWaitFor<T>(
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

}

