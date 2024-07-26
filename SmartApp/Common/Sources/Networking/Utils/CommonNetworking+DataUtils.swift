//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

//
// DataUtils
//

public extension CommonNetworking {
    enum DataUtils {
        /// this function is fetching the json from URL
        public static func dataFrom(
            _ urlString: String,
            completion: @escaping ((Data?, Bool) -> Void)
        ) {
            guard let url = URL(string: urlString) else {
                assertionFailure("Invalid url : \(urlString)")
                completion(nil, false)
                return
            }
            URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
                guard let httpURLResponse = response as? HTTPURLResponse,
                      httpURLResponse.statusCode == 200,
                      let data,
                      error == nil
                else {
                    assertionFailure("\(String(describing: error))")
                    DispatchQueue.main.async { completion(nil, false) }
                    return
                }
                DispatchQueue.main.async { completion(data, true) }
            }).resume()
        }
    }
}
