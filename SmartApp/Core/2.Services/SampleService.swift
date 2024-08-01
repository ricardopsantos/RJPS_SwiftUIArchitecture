//
//  SampleService.swift
//  SmartApp
//
//  Created by Ricardo Santos on 20/05/2024.
//

import Foundation
//
import Domain
import Common

public class SampleService {
    private init() {}
    public static let shared = SampleService()
}

extension SampleService: SampleServiceProtocol {
    public static func doSomething(param: String) async throws -> String {
        "something"
    }
}
