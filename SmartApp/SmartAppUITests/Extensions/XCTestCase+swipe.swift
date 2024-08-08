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
    func swipe(
        scrollView: String,
        swipeUp: Bool = false,
        swipeDown: Bool = false,
        velocity: XCUIGestureVelocity = .default,
        on app: XCUIApplication
    ) {
        let scrollview = app.scrollViews[scrollView]
        let element = scrollview.children(matching: .other).element.children(matching: .other).element
        if swipeUp {
            element.swipeUp(velocity: velocity)
        }
        if swipeDown {
            element.swipeDown(velocity: velocity)
        }
    }

    func swipeUp(
        scrollView: String,
        staticTexts: String,
        swipeUp: Bool = false,
        swipeDown: Bool = false,
        velocity: XCUIGestureVelocity = .default,
        on app: XCUIApplication
    ) {
        let scrollview = app.scrollViews[scrollView]
        if swipeUp {
            scrollview.otherElements.staticTexts[staticTexts]
                .swipeUp(velocity: velocity)
        }
        if swipeDown {
            scrollview.otherElements.staticTexts[staticTexts]
                .swipeDown(velocity: velocity)
        }
    }
}
