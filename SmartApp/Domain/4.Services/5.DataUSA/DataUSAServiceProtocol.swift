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
    func requestPopulationStateData(
        _ request: ModelDto.PopulationStateDataRequest,
        cachePolicy: ServiceCachePolicy
    ) async throws -> ModelDto.PopulationStateDataResponse

    func requestPopulationNationData(
        _ request: ModelDto.PopulationNationDataRequest,
        cachePolicy: ServiceCachePolicy
    ) async throws -> ModelDto.PopulationNationDataResponse
}
