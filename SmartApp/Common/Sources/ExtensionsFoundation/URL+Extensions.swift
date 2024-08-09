//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public extension URL {
    private func splitQuery(_ query: String) -> [String: [String]] {
        query
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce(into: [String: [String]]()) { result, element in
                guard !element.isEmpty,
                      let key = element[0].removingPercentEncoding,
                      let value = element.count >= 2 ? element[1].removingPercentEncoding : "" else {
                    return
                }
                var values = result[key, default: [String]()]
                values.append(value)
                result[key] = values
            }
    }

    var fragmentItems: [String: [String]] {
        guard let fragment else {
            return [:]
        }
        return splitQuery(fragment)
    }

    var queryItems: [String: [String]] {
        guard let query else {
            return [:]
        }
        return splitQuery(query)
    }

    var schemeAndHostURL: URL? {
        guard let scheme, let host else {
            return nil
        }
        return URL(string: scheme + "://" + host)
    }
}
