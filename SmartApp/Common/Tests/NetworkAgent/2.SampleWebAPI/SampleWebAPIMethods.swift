//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
@testable import Common

public enum SampleWebAPIMethods {
    case fetchEmployees(_ request: RequestDto.Employee)
    case updateEmployee(_ request: RequestDto.Employee)
}

extension SampleWebAPIMethods {
    /// Url paramenters
    var queryItems: [String: String?] {
        switch self {
        case .updateEmployee(let request):
            return [
                "id": request.id,
                "timezone": TimeZone.autoupdatingCurrent.identifier
            ]
        default:
            return [:]
        }
    }
    
    var parameters: Encodable? {
        switch self {
        case .updateEmployee(let some):
            return some
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
        case .fetchEmployees:
            (
                .get,
                "https://gist.githubusercontent.com/ricardopsantos/10a31da1c6981acd216a93cb040524b9",
                "raw/8f0f03e6bdfe0dd522ff494022f3aa7a676e882f/Article_13_G8.json"
            )
        case .updateEmployee:
            (
                .post,
                "https://gist.githubusercontent.com/ricardopsantos/10a31da1c6981acd216a93cb040524b9",
                "raw/8f0f03e6bdfe0dd522ff494022f3aa7a676e882f/Article_13_G8.json"
            )
        }
    }
    
    /// Sugar name
    var name: String {
        switch self {
        case .fetchEmployees: "fetchEmployees"
        case .updateEmployee: "updateUser"
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
}
