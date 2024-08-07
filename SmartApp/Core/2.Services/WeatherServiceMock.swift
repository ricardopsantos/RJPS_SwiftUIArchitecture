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
import DevTools

public class WeatherServiceMock {
    private init() {}
    public static let shared = WeatherServiceMock()
}

extension WeatherServiceMock: WeatherServiceProtocol {
    public func getWeather(
        _ request: ModelDto.GetWeatherRequest,
        cachePolicy: ServiceCachePolicy) async throws -> ModelDto.GetWeatherResponse {
            .mock!
    }
}
