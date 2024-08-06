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

    private let cacheManager = Common.SimpleCacheManagerForCodable.shared
}

extension DataUSAService: DataUSAServiceProtocol {
    public func requestPopulationStateData(
        _ request: ModelDto.PopulationStateDataRequest,
        cachePolicy: DataUSAServiceCachePolicy
    ) async throws -> ModelDto.PopulationStateDataResponse {
        let cacheKey = "\(#function)"
        let cacheParams: [any Hashable] = [request.year, request.drilldowns, request.measures]
        let cacheType = ModelDto.PopulationStateDataResponse.self
        
        if let cached = cacheManager.syncRetrieve(cacheType, key: cacheKey, params: cacheParams), cachePolicy == .cacheElseLoad {
            DevTools.Log.debug(.log("Returned cache for \(#function)"), .business)
            return cached.model
        }

        guard Common_Utils.existsInternetConnection else {
            throw AppErrors.noInternet
        }

        let result = try await NetworkManager.shared.request(
            .getPopulationStateData(request),
            type: cacheType
        )
        
        cacheManager.syncStore(result, key: cacheKey, params: cacheParams)
        
        return result
    }

    public func requestPopulationNationData(
        _ request: ModelDto.PopulationNationDataRequest,
        cachePolicy: DataUSAServiceCachePolicy
    ) async throws -> ModelDto.PopulationNationDataResponse {
        let cacheKey = "\(#function)"
        let cacheParams: [any Hashable] = [request.drilldowns, request.measures]
        let cacheType = ModelDto.PopulationNationDataResponse.self
        if let cached = cacheManager.syncRetrieve(cacheType, key: cacheKey, params: cacheParams), cachePolicy == .cacheElseLoad {
            DevTools.Log.debug(.log("Returned cache for \(#function)"), .business)
            return cached.model
        }

        guard Common_Utils.existsInternetConnection else {
            throw AppErrors.noInternet
        }

        let result = try await NetworkManager.shared.request(
            .getPopulationNationData(request),
            type: cacheType
        )
        cacheManager.syncStore(result, key: cacheKey, params: cacheParams)
        return result
    }
}
