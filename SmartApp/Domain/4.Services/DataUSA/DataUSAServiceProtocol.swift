//
//  DataUSAServiceProtocol.swift
//  Domain
//
//  Created by Ricardo Santos on 02/08/2024.
//

import Foundation
//
import Common

public protocol DataUSAServiceProtocol {
    func requestStateData(_ request: ModelDto.StateRequest) async throws -> ModelDto.StateResponse

    func requestNationData(_ request: ModelDto.NationRequest) async throws -> ModelDto.NationResponse
}
