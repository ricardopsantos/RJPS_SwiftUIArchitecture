//
//  WeatherService.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import Common

public protocol WeatherServiceProtocol {
    func getWeather(_ request: ModelDto.GetWeatherRequest,
                    cachePolicy: ServiceCachePolicy) async throws -> ModelDto.GetWeatherResponse
}
