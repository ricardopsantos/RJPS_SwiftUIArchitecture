//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public extension URLRequest {
    var cronometerId: String {
        var id: String = ""
        if let httpMethod {
            id += "\(httpMethod)".uppercased()
        }
        if let absoluteString = url?.absoluteString {
            id += "|\(absoluteString))"
        }
        return id
    }

    @discardableResult
    func curlCommand(
        doPrint: Bool,
        // prefixCount: Int = Int.max,
        maxLogSize: Int = Common.LogsManager.maxLogSize
    ) -> String? {
        guard let url else {
            return nil
        }

        let newLine = ""
        var command = "curl '\(url.absoluteString)'\(newLine)"

        // Set method
        if let httpMethod {
            command += " -X \(httpMethod)\(newLine)"
        }

        // Set headers
        if let headers = allHTTPHeaderFields {
            let headersSorted = headers.sorted(by: { $0.key < $1.key })
            for (key, value) in headersSorted {
                command += " -H '\(key): \(value)'\(newLine)"
            }
        }

        // Set body data
        if let bodyData = httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
            command += " -d '\(bodyString)'\(newLine)"
        }
        command = command.dropLastIf(newLine)
        if doPrint {
            // swiftlint:disable logs_rule_1
            if command.count > maxLogSize {
                print(command.prefix(maxLogSize))
            } else {
                print(command)
            }
            // swiftlint:enable logs_rule_1
        }
        return command
    }

    static func with(
        urlString: String,
        httpMethod: String,
        httpBody: [String: Any]?,
        headerValues: [String: String]?
    ) -> URLRequest? {
        guard let theURL = URL(string: "\(urlString)") else {
            Common.LogsManager.warning("Invalid url [\(urlString)]")
            return nil
        }
        var request = URLRequest(url: theURL)
        request.httpMethod = httpMethod.uppercased()

        if let httpBody {
            if httpBody.keys.count == 1, let dataRaw = httpBody["data-raw"] as? String {
                /**
                 curl --request POST 'https://login.microsoftonline.com/xxx-82a0-4bff-b9e9-xxxx/oauth2/token' \
                 --header 'Content-Type: application/x-www-form-urlencoded' \
                 --data-raw 'client_id=xxxx-f206-xxxx-86d8-xxxx&client_secret=b13828ebbc09a965bc&grant_type=client_credentials&resource=https://api.xxxx.com/b2bgateway'
                 */
                request.httpBody = Data(dataRaw.utf8)
            } else if !httpBody.keys.isEmpty {
                request.httpBody = try? JSONSerialization.data(withJSONObject: httpBody, options: .prettyPrinted)
                if !httpBody.isEmpty, request.httpBody == nil {
                    Common.LogsManager.error("Fail to serialize httpBody:\n\n\(httpBody)")
                }
            }
        }

        headerValues?.sorted(by: { $0.key < $1.key }).forEach { kv in
            request.addValue(kv.value, forHTTPHeaderField: kv.key)
        }

        return request
    }
}
