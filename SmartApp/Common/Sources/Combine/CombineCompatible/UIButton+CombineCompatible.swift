//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import UIKit

public extension CombineCompatible {
    var touchUpInsidePublisher: AnyPublisher<UIControl, Never> { target.touchUpInsidePublisher }
    var touchDownRepeatPublisher: AnyPublisher<UIControl, Never> { target.touchDownRepeatPublisher }
}

public extension CombineCompatibleProtocol where Self: UIControl {
    var touchUpInsidePublisher: AnyPublisher<Self, Never> {
        Common.UIControlPublisher(
            control: self,
            events: [.touchUpInside]
        ).eraseToAnyPublisher()
    }

    var touchDownRepeatPublisher: AnyPublisher<Self, Never> {
        Common.UIControlPublisher(
            control: self,
            events: [.touchDownRepeat]
        ).eraseToAnyPublisher()
    }
}

// swiftlint:disable no_UIKitAdhocConstruction
fileprivate extension Common {
    func sample() {
        let btn = UIButton()
        _ = btn.publisher(for: .touchUpInside).sinkToReceiveValue { _ in }
        _ = btn.combine.touchUpInsidePublisher.sinkToReceiveValue { _ in }
        _ = btn.touchUpInsidePublisher.sinkToReceiveValue { _ in }

        // btn.onTouchUpInside {}
        // btn.onTouchUpInside {}

        btn.sendActions(for: .touchUpInside)
    }
}

// swiftlint:enable no_UIKitAdhocConstruction
