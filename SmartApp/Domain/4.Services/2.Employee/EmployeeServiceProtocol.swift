//
//  EmployeeService.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import Combine
//
import Common

public protocol EmployeeServiceProtocol {
    func requestEmployeesAsync(_ request: ModelDto.EmployeeRequest) async throws -> ModelDto.EmployeeResponse

    typealias ResponseEmployeesWithCacheMaybe = AnyPublisher<ModelDto.EmployeeResponse, AppErrors>
    func requestEmployeesAsPublisher(
        _ request: ModelDto.EmployeeRequest,
        cachePolicy: Common.CachePolicy
    ) -> ResponseEmployeesWithCacheMaybe

    typealias ResponseEmployeesWithCacheMaybeAsStream = AsyncStream<ModelDto.EmployeeResponse>
    func requestEmployeesAsStream(
        _ request: ModelDto.EmployeeRequest,
        cachePolicy: Common.CachePolicy
    ) -> ResponseEmployeesWithCacheMaybeAsStream
}
