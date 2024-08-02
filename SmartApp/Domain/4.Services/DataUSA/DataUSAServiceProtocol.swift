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
    func requestPopulationStateData(_ request: ModelDto.PopulationStateDataRequest) async throws -> ModelDto.PopulationStateDataResponse

    func requestPopulationNationData(_ request: ModelDto.PopulationNationDataRequest) async throws -> ModelDto.PopulationNationDataResponse
}
