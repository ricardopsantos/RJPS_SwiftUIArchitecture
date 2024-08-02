//
//  APIEndpoints.swift
//  SmartApp
//
//  Created by Ashok Choudhary on 03/01/24.
//  Changed/Updated by Ricardo Santos on 15/04/2024.
//
import Common

enum APIEndpoints {
    case getPopulationNationData(_ request: ModelDto.PopulationNationDataRequest)
    case getPopulationStateData(_ request: ModelDto.PopulationStateDataRequest)
}

extension APIEndpoints {
    var urlParameters: [String: String?] {
        switch self {
        case .getPopulationNationData(let request):
            return [
                "drilldowns": request.drilldowns,
                "measures": request.measures
            ]
        case .getPopulationStateData(let request):
            return [
                "drilldowns": request.drilldowns,
                "measures": request.measures,
                "year": request.year
            ]
        }
    }

    var parameters: Encodable? {
        switch self {
        default:
            return nil
        }
    }

    var data: (
        httpMethod: CommonNetworking.HttpMethod,
        serverURL: String,
        path: String
    ) {
        switch self {
        case .getPopulationNationData: (
                .get,
                "https://datausa.io/api",
                "data"
            )
        case .getPopulationStateData: (
                .get,
                "https://datausa.io/api",
                "data"
            )
        }
    }
}
