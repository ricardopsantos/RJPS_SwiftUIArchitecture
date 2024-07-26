//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

extension CommonNetworking {
    struct Utils {
        static func parseCSV(data: Data) throws -> Data {
            let dataString: String! = String(data: data, encoding: .utf8)

            guard let jsonKeys: [String] = dataString.components(separatedBy: "\n").first?.components(separatedBy: ",") else {
                throw APIError.parsing(description: "\(Utils.self) CSV parsing fail", data: data)
            }

            var parsedCSV: [[String: String]] = dataString
                .components(separatedBy: "\n")
                .map {
                    var result = [String: String]()
                    for (index, value) in $0.components(separatedBy: ",").enumerated() {
                        if index < jsonKeys.count {
                            result["\(jsonKeys[index])"] = value
                        }
                    }
                    return result
                }

            parsedCSV.removeFirst()

            guard let jsonData = try? JSONSerialization.data(withJSONObject: parsedCSV, options: []) else {
                throw APIError.parsing(description: "\(Utils.self) CSV parsing fail", data: data)
            }

            return jsonData
        }
    }
}
