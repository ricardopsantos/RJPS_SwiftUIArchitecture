//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import UIKit

public extension Common.GenericChangesPublisher {
    typealias GenericChangesPublisherOutput = (
        instanceClass: String,
        instanceId: String,
        propName: String,
        propValue: Any?,
        date: Date
    )
    func emit(
        _ instanceClass: String,
        _ instanceId: String,
        _ propName: String,
        _ propValue: Any?
    ) {
        subject.send((instanceClass, instanceId, propName, propValue, Date.utcNow))
    }
}

public extension Common {
    /// Helper class to publish changes
    class GenericChangesPublisher {
        public var publisher: AnyPublisher<GenericChangesPublisherOutput, Never> { subject.eraseToAnyPublisher() }
        private let subject = PassthroughSubject<GenericChangesPublisherOutput, Never>()
        public init() {}

        static func sampleUsage() {
            @PWThreadSafe var changesPublisher: GenericChangesPublisher = GenericChangesPublisher()
            changesPublisher.emit("instanceClass", "instanceId", "propName", "propValue")
        }
    }
}
