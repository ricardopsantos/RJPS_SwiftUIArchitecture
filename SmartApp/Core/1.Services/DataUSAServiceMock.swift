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
    public func requestPopulationStateData(_ request: ModelDto.PopulationStateDataRequest) async throws -> ModelDto.PopulationStateDataResponse {
        return ModelDto.PopulationStateDataResponse.mock!
    }

    public func requestPopulationNationData(_ request: ModelDto.PopulationNationDataRequest) async throws -> ModelDto.PopulationNationDataResponse {
        return ModelDto.PopulationNationDataResponse.mock!
    }
}
