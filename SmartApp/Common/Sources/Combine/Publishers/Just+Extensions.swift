//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import SwiftUI
import Combine
import Foundation

public extension Just where Output == Void {
    static func withErrorType<E>(_ errorType: E.Type) -> AnyPublisher<Void, E> {
        withErrorType((), E.self)
    }
}

public extension Just {
    static func withErrorType<E>(
        _ value: Output,
        _ errorType: E.Type
    ) -> AnyPublisher<Output, E> {
        Just(value)
            .setFailureType(to: E.self)
            .eraseToAnyPublisher()
    }
}
