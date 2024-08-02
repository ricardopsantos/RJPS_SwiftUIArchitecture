//
//  WeatherService.swift
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
    public func requestStateData(_ request: ModelDto.StateRequest) async throws -> ModelDto.StateResponse {
        try await NetworkManager.shared.request(
            .getStateData(request),
            type: ModelDto.StateResponse.self
        )
    }

    public func requestNationData(_ request: ModelDto.NationRequest) async throws -> ModelDto.NationResponse {
        try await NetworkManager.shared.request(
            .getNationData(request),
            type: ModelDto.NationResponse.self
        )
    }

    public func getWeather(_ request: ModelDto.GetWeatherRequest) async throws -> ModelDto.GetWeatherResponse {
        try await NetworkManager.shared.request(
            .getWeather(request),
            type: ModelDto.GetWeatherResponse.self
        )
    }
}
