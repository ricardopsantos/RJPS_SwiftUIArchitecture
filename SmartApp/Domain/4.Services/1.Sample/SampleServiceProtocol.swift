//
//  SampleService.swift
//  SmartApp
//
//  Created by Ricardo Santos on 20/05/2024.
//

import Foundation
//
import Common

public protocol SampleServiceProtocol {
    static func doSomething(param: String) async throws -> String
}
