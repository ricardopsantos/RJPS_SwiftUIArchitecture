//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public extension URLResponse {
    var devMessage: String {
        var message = ""
        if let absoluteString = url?.absoluteString {
            message += "url: \(absoluteString) | "
        }
        if let mimeType {
            message += "mimeType: \(mimeType) | "
        }
        if let textEncodingName {
            message += "textEncodingName: \(textEncodingName) | "
        }
        return message.replace("Optional", with: "").replace("(", with: "").replace(")", with: "").replace("\"", with: "")
    }
}
