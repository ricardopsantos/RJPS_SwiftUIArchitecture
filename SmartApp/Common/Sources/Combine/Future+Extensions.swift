//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import Combine

public extension Future where Failure == Error {
    /**
     https://swiftbysundell.com/articles/creating-combine-compatible-versions-of-async-await-apis/

     Usage:
     ```
     Future {
        try await self.loadModel(from: url)
     }
     ```
     */
    convenience init(operation: @escaping () async throws -> Output) {
        self.init { promise in
            Task {
                do {
                    let output = try await operation()
                    promise(.success(output))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
