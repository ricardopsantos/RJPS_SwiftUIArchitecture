//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

/*
 https://medium.com/@jpmtech/level-up-your-career-by-adding-ui-tests-to-your-swiftui-app-37cbffeba459
 */

@testable import Smart_Dev

import XCTest
import Combine
import Nimble
//
import Common

final class EditUserInfoTests: BaseUITests {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    func testA1_editUserNameAndMail() {
        appLaunch(launchArguments: [
            "isAuthenticated"
        ])
        tap(
            tabBarIndex: 3,
            andWaitForStaticText: Constants.tab4Title,
            on: app
        )
        tap(
            button: "Update",
            andWaitForStaticText: "UpdateUserDetails",
            on: app
        )
        let newName = "NewName"+Int.random(in: 1...100).description
        let newMail = newName + "@mail.com"
        tap(
            textField: "txtUserName",
            andType: newName,
            dismissKeyboard: false,
            on: app,
            delayBeforeTap: 0,
            delayBeforeType: 0
        )
        tap(
            textField: "txtEmail",
            andType: newMail,
            dismissKeyboard: true,
            on: app,
            delayBeforeTap: 0,
            delayBeforeType: 0
        )
        tap(button: "Save", andWaitForStaticText: "SaveUserInfoBottomSheetTitle", on: app)
        tap(button: "Yes", andWaitForStaticText: Constants.tab4Title, on: app)
        
        exists(staticText: newName, on: app)
        exists(staticText: newMail, on: app)
    }


}
