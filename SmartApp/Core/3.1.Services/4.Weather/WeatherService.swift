//
//  WeatherService.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import Common

public class WeatherService {
    private init() {}
    public static let shared = WeatherService()
}

extension WeatherService: WeatherServiceProtocol {
    public func getWeather(_ request: ModelDto.GetWeatherRequest) async throws -> ModelDto.GetWeatherResponse {
        try await NetworkManager.shared.request(
            .getWeather(request),
            type: ModelDto.GetWeatherResponse.self
        )
    }
}
