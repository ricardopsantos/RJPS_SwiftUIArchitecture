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

public class DataUSAService {
    private init() {}
    public static let shared = DataUSAService()
}

extension DataUSAService: DataUSAServiceProtocol {
    public func requestPopulationStateData(_ request: ModelDto.PopulationStateDataRequest) async throws -> ModelDto.PopulationStateDataResponse {
        guard Common_Utils.existsInternetConnection else {
            throw AppErrors.noInternet
        }
        return try await NetworkManager.shared.request(
            .getPopulationStateData(request),
            type: ModelDto.PopulationStateDataResponse.self
        )
    }

    public func requestPopulationNationData(_ request: ModelDto.PopulationNationDataRequest) async throws -> ModelDto.PopulationNationDataResponse {
        guard Common_Utils.existsInternetConnection else {
            throw AppErrors.noInternet
        }
        return try await NetworkManager.shared.request(
            .getPopulationNationData(request),
            type: ModelDto.PopulationNationDataResponse.self
        )
    }
}
