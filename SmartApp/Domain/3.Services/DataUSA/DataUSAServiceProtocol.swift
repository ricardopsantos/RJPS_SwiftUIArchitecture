//
//  DataUSAServiceProtocol.swift
//  Domain
//
//  Created by Ricardo Santos on 02/08/2024.
//

import Foundation
//
import Common

public enum DataUSAServiceCachePolicy {
    case cacheElseLoad
    case load
}

public protocol DataUSAServiceProtocol {
    func requestPopulationStateData(
        _ request: ModelDto.PopulationStateDataRequest,
        cachePolicy: DataUSAServiceCachePolicy
    ) async throws -> ModelDto.PopulationStateDataResponse

    func requestPopulationNationData(
        _ request: ModelDto.PopulationNationDataRequest,
        cachePolicy: DataUSAServiceCachePolicy
    ) async throws -> ModelDto.PopulationNationDataResponse
}
