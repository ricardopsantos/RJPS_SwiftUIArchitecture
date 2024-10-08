//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public extension Encodable {
    func toData() throws -> Data {
        try JSONEncoder().encode(self)
    }

    var sizeInMB: Double {
        do {
            let dataSizeInBytes = try Double(toData().count)
            let sizeInMB = dataSizeInBytes / (1024 * 1024)
            return sizeInMB
        } catch {
            return 0
        }
    }
}

public extension Data {
    var utf8String: String? {
        String(data: self, encoding: .utf8)
    }

    var jsonString: String? {
        guard let json = try? JSONSerialization.jsonObject(with: self, options: []) else {
            return nil
        }
        if let jsonData = try? JSONSerialization.data(withJSONObject: json as Any, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return nil
    }

    func toObject<D: Decodable>() throws -> D {
        try JSONDecoder().decodeFriendly(D.self, from: self)
    }

    var sizeInMB: Double {
        let sizeInBytes = Double(count)
        let sizeInMB = sizeInBytes / (1024 * 1024)
        return sizeInMB
    }
}
