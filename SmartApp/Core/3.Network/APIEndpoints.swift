//
//  APIEndpoints.swift
//  SmartApp
//
//  Created by Ashok Choudhary on 03/01/24.
//  Changed/Updated by Ricardo Santos on 15/04/2024.
//
import Common

enum APIEndpoints {
    case getWeather(_ request: ModelDto.GetWeatherRequest)
    case updateUser(_ request: ModelDto.UpdateUserRequest)
    case requestEmployees(_ request: ModelDto.EmployeeRequest)
    case getPopulationNationData(_ request: ModelDto.PopulationNationDataRequest)
    case getPopulationStateData(_ request: ModelDto.PopulationStateDataRequest)
}

extension APIEndpoints {
    /// Sugar name used on chronometer
    var name: String {
        switch self {
        case .getWeather: "getWeather"
        case .updateUser: "updateUser"
        case .requestEmployees: "requestEmployees"
        case .getPopulationNationData: "getPopulationNationData"
        case .getPopulationStateData: "getPopulationStateData"
        }
    }

    // URL Params
    var queryItems: [String: String?] {
        switch self {
        case .getWeather(let request):
            return [
                "latitude": request.latitude,
                "longitude": request.longitude,
                "daily": "temperature_2m_max,temperature_2m_min",
                "timezone": TimeZone.autoupdatingCurrent.identifier
            ]
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
        default:
            return [:]
        }
    }

    var parameters: Encodable? {
        switch self {
        case .updateUser(let user):
            return user
        default:
            return nil
        }
    }

    var headerValues: [String: String]? {
        nil
    }

    var httpBody: [String: Any]? {
        nil
    }

    var responseType: CommonNetworking.ResponseFormat {
        .json
    }

    var data: (
        httpMethod: CommonNetworking.HttpMethod,
        serverURL: String,
        path: String
    ) {
        switch self {
        case .getWeather:
            (
                .get,

                "https://api.open-meteo.com/v1/",
                "forecast"
            )
        case .updateUser:
            (
                .put,

                "/api/v1/users",
                "users"
            )
        case .requestEmployees(let request): (
                .get,
                "https://gist.githubusercontent.com/ricardopsantos/10a31da1c6981acd216a93cb040524b9",
                "/raw/8f0f03e6bdfe0dd522ff494022f3aa7a676e882f/\(request.json)"
            )
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
