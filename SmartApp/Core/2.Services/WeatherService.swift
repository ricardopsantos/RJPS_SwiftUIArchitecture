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

public class WeatherService {
    private init() {}
    public static let shared = WeatherService()
//    private let cacheManager = Common.CacheManagerForCodableUserDefaultsRepository.shared
    private let cacheManager = Common.CacheManagerForCodableCoreDataRepository.shared
}

extension WeatherService: WeatherServiceProtocol {
    public func getWeather(
        _ request: ModelDto.GetWeatherRequest,
        cachePolicy: ServiceCachePolicy) async throws -> ModelDto.GetWeatherResponse {
        let cacheKey = "\(#function)"
        let cacheParams: [any Hashable] = [request.latitude, request.longitude]
        let responseType = ModelDto.GetWeatherResponse.self

        if let cached = await cacheManager.aSyncRetrieve(responseType, key: cacheKey, params: cacheParams), cachePolicy == .cacheElseLoad {
            DevTools.Log.debug(.log("Returned cache for \(#function)"), .business)
            return cached.model
        }

        guard DevTools.existsInternetConnection else {
            throw AppErrors.noInternet
        }

        let result = try await NetworkManager.shared.request(
            .getWeather(request),
            type: responseType)

        await cacheManager.aSyncStore(result, key: cacheKey, params: cacheParams)

        return result
    }
}
