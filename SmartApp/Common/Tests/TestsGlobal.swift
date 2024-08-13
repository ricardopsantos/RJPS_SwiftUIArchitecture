//
//  File.swift
//
//
//  Created by Ricardo Santos on 23/07/2024.
//

import Foundation

import XCTest
import Combine
import Nimble
import Common

internal class CommonBundleFinder {}

public struct TestsGlobal {
    static let cancelBag = CancelBag()
    static var timeout: Int = 5
    static var loadedAny: Any?
    static var internalDB: String { "CommonInternalDBTestTwin.xcdatamodeld" }
    static var bundleIdentifier: String {
        Bundle(for: CommonBundleFinder.self).bundleIdentifier ?? ""
    }
}
