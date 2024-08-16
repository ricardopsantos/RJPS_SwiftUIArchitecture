//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

/// @testable import comes from the ´PRODUCT_NAME´ on __.xcconfig__ file

@testable import Smart_Dev

import XCTest
import Combine
import Nimble
import ViewInspector
import SwiftUI
//
import Domain
import Core
import Common

final class CommonLearningsTests: XCTestCase {
    var enabled: Bool = false

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        loadedAny = nil
        cancelBag.cancel()
    }

    func testListItems() throws {
        guard enabled else { return }
        let view = CommonLearnings.ListTechniques.SimpleListView()
        let list = try view.inspect().list()
        XCTAssert(list.count == CommonLearnings.ListTechniques.items1.count)
        XCTAssert(try list.text(0).string() == CommonLearnings.ListTechniques.items1.first ?? "")
    }

    func testSwipeAction() throws {
        guard enabled else { return }
        let view = CommonLearnings.ListTechniques.ReorderableListView()
        let indexPath = IndexSet(integer: 0)
        view.move(from: indexPath, to: 1)
        XCTAssert(view.items[1] == CommonLearnings.ListTechniques.items1[1])
    }

    func testText() throws {
        guard enabled else { return }
        let sut = Text("Completed by \(72.51, specifier: "%.1f")%").font(.caption)
        let string = try sut.inspect().text().string(locale: Locale(identifier: "es"))
        XCTAssert(string == "Completado por 72,5%")
        XCTAssert(try sut.inspect().text().attributes().font() == .caption)
    }
}
