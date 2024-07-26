//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

//
// JSON
//

public extension CommonNetworking {
    enum JSONUtils {
        /// Returns in success, Dictionary<String, Any> or [Dictionary<String, Any>]
        static func jsonFrom(
            _ urlString: String,
            completion: @escaping ((AnyObject?, Bool) -> Void)
        ) {
            DataUtils.dataFrom(urlString) { data, success in
                guard success else {
                    completion(nil, success)
                    return
                }
                if let object = try? JSONSerialization.jsonObject(with: data!, options: []) {
                    if let json = object as? [String: Any] {
                        completion(json as AnyObject, true)
                    } else if let jsonArray = object as? [[String: Any]] {
                        completion(jsonArray as AnyObject, true)
                    } else {
                        completion(nil, false)
                    }
                } else {
                    completion(nil, false)
                }
            }
        }
    }
}
