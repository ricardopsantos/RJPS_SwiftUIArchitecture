//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import UIKit

public extension Common {
    /**
     While both `GenericObservableObjectForHashable` and `ObservableValueHolder` classes achieve
     a similar goal of providing a generic observable object, there is a significant difference between the two due to the
     way they publish changes:

     __GenericObservableObjectForHashable__:
     This class uses a PassthroughSubject to publish changes. It means that you need to manually send values
     through the subject to notify observers. For example, you would call `.send(_:)` on the value property
     to trigger the observers when the value changes.

     __ObservableValueHolder__:
     This class uses the @Published property wrapper, which automatically publishes changes to its subscribers
     whenever the value property is updated. You don't need to manually trigger publication; it's done automatically
     by the Combine framework.

     In summary:

     * If you use `GenericObservableObjectForHashable`, you will need to manually send values
     through the PassthroughSubject to notify observers.

     If you use `ObservableValueHolder`, changes to the value property are automatically published to observers
     using the _@Published_ property wrapper.

     Depending on your needs, the choice between the two classes will depend on whether you want to manually control when changes are published or have it handled automatically.
     */

    class HashableValueObserver<T: Hashable>: ObservableObject {
        public init() {}
        public var value = PassthroughSubject<T, Never>()
    }

    class ObservableValueHolder<T: Hashable>: ObservableObject {
        public init() {}
        /// The current value held by the observable object.
        @Published var value: T?
    }
}
