//
//  UserService.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
//
import Domain
import Common

public class UserService {
    private init() {}
    public static let shared = UserService()
}

extension UserService: UserServiceProtocol {
    public static func updateUser(_ request: ModelDto.UpdateUserRequest) async throws -> ModelDto.UpdateUserResponse {
        try await NetworkManager.shared.requestAsync(
            .updateUser(request)
        )
    }
}
