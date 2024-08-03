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
import DevTools

public class DataUSAService {
    private init() {}
    public static let shared = DataUSAService()
    
    /**
     __IMPORTANT__: This is a very simple cache approach. Usually I do it this way [Enhancing mobile app user experience through efficient caching in Swift](https://ricardojpsantos.medium.com/enhancing-mobile-app-user-experience-through-efficient-caching-in-swift-c970554eab84) or 
     */
    private let populationCache = CacheManager<String, ModelDto.PopulationStateDataResponse>()
    private let nationCache = CacheManager<String, ModelDto.PopulationNationDataResponse>()
}

extension DataUSAService: DataUSAServiceProtocol {
    public func requestPopulationStateData(
        _ request: ModelDto.PopulationStateDataRequest,

        cachePolicy: DataUSAServiceCachePolicy
    ) async throws -> ModelDto.PopulationStateDataResponse {
        let cacheKey = "\(#function)_\(request.hashValue)"
        if let cached = populationCache.value(forKey: cacheKey), cachePolicy == .cacheElseLoad {
            DevTools.Log.debug(.log("Returned cache for \(#function)"), .business)
            return cached
        }

        guard Common_Utils.existsInternetConnection else {
            throw AppErrors.noInternet
        }

        let result = try await NetworkManager.shared.request(
            .getPopulationStateData(request),
            type: ModelDto.PopulationStateDataResponse.self
        )
        populationCache.insert(result, forKey: cacheKey)
        return result
    }

    public func requestPopulationNationData(
        _ request: ModelDto.PopulationNationDataRequest,
        cachePolicy: DataUSAServiceCachePolicy
    ) async throws -> ModelDto.PopulationNationDataResponse {
        let cacheKey = "\(#function)_\(request.hashValue)"
        if let cached = nationCache.value(forKey: cacheKey), cachePolicy == .cacheElseLoad {
            DevTools.Log.debug(.log("Returned cache for \(#function)"), .business)
            return cached
        }
        guard Common_Utils.existsInternetConnection else {
            throw AppErrors.noInternet
        }
        let result = try await NetworkManager.shared.request(
            .getPopulationNationData(request),
            type: ModelDto.PopulationNationDataResponse.self
        )
        nationCache.insert(result, forKey: cacheKey)
        return result
    }
}
