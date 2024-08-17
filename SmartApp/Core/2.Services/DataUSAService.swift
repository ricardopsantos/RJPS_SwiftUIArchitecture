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

    //    private let cacheManager = Common.CacheManagerForCodableUserDefaultsRepository.shared
    private let cacheManager = Common.CacheManagerForCodableCoreDataRepository.shared
    private let webAPI: NetworkManager = .shared
}

extension DataUSAService: DataUSAServiceProtocol {
    public func requestPopulationStateData(
        _ request: ModelDto.PopulationStateDataRequest,
        cachePolicy: ServiceCachePolicy
    ) async throws -> ModelDto.PopulationStateDataResponse {
        let cacheKey = "\(#function)"
        let cacheParams: [any Hashable] = [request.year, request.drilldowns, request.measures]
        let responseType = ModelDto.PopulationStateDataResponse.self

        if let cached = await cacheManager.aSyncRetrieve(responseType, key: cacheKey, params: cacheParams), cachePolicy == .cacheElseLoad {
            DevTools.Log.debug(.log("Returned cache for \(#function)"), .business)
            return cached.model
        }

        guard DevTools.existsInternetConnection else {
            throw AppErrors.noInternet
        }

        let result: ModelDto.PopulationStateDataResponse = try await webAPI.requestAsync(
            .getPopulationStateData(request)
        )

        await cacheManager.aSyncStore(result, key: cacheKey, params: cacheParams)

        return result
    }

    public func requestPopulationNationData(
        _ request: ModelDto.PopulationNationDataRequest,
        cachePolicy: ServiceCachePolicy
    ) async throws -> ModelDto.PopulationNationDataResponse {
        let cacheKey = "\(#function)"
        let cacheParams: [any Hashable] = [request.drilldowns, request.measures]
        let responseType = ModelDto.PopulationNationDataResponse.self
        if let cached = await cacheManager.aSyncRetrieve(responseType, key: cacheKey, params: cacheParams), cachePolicy == .cacheElseLoad {
            DevTools.Log.debug(.log("Returned cache for \(#function)"), .business)
            return cached.model
        }

        guard DevTools.existsInternetConnection else {
            throw AppErrors.noInternet
        }

        let result: ModelDto.PopulationNationDataResponse = try await webAPI.requestAsync(
            .getPopulationNationData(request)
        )
        await cacheManager.aSyncStore(result, key: cacheKey, params: cacheParams)
        return result
    }
}
