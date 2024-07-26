//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import Combine

// MARK: - UIBarButtonItem

public extension UIBarButtonItem {
    final class Subscription<SubscriberType: Subscriber, Input: UIBarButtonItem>: Combine.Subscription where SubscriberType.Input == Input {
        private var subscriber: SubscriberType?
        private let input: Input

        public init(subscriber: SubscriberType, input: Input) {
            self.subscriber = subscriber
            self.input = input
            input.target = self
            input.action = #selector(eventHandler)
        }

        public func request(_ demand: Subscribers.Demand) {}

        public func cancel() {
            subscriber = nil
        }

        @objc private func eventHandler() {
            _ = subscriber?.receive(input)
        }
    }

    struct Publisher<Output: UIBarButtonItem>: Combine.Publisher {
        public typealias Output = Output
        public typealias Failure = Never

        let output: Output

        public init(output: Output) {
            self.output = output
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = Subscription(subscriber: subscriber, input: output)
            subscriber.receive(subscription: subscription)
        }
    }
}
