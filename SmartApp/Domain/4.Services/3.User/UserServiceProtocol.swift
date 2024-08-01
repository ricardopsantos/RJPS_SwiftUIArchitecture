//
//  UserServiceProtocol.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import Common

public protocol UserServiceProtocol {
    static func updateUser(_ request: ModelDto.UpdateUserRequest) async throws -> ModelDto.UpdateUserResponse
}
