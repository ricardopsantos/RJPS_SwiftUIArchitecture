//
//  DataUSAService.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
//
import Domain
import Common

public class DataUSAServiceMock {
    private init() {}
    public static let shared = DataUSAServiceMock()
}

extension DataUSAServiceMock: DataUSAServiceProtocol {
    public func requestPopulationStateData(
        _ request: ModelDto.PopulationStateDataRequest,
        cachePolicy: ServiceCachePolicy
    ) async throws -> ModelDto.PopulationStateDataResponse {
        ModelDto.PopulationStateDataResponse.mockBigLoad!
    }

    public func requestPopulationNationData(
        _ request: ModelDto.PopulationNationDataRequest,
        cachePolicy: ServiceCachePolicy
    ) async throws -> ModelDto.PopulationNationDataResponse {
        ModelDto.PopulationNationDataResponse.mockBigLoad!
    }
}
