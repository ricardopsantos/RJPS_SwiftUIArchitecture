//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Combine
import CoreData

public struct ASyncCoreDataManagerSavePublisher: Publisher {
    public typealias Output = Bool
    public typealias Failure = NSError

    private let action: ASyncCoreDataManagerPublisherAction
    private let context: NSManagedObjectContext

    init(action: @escaping ASyncCoreDataManagerPublisherAction, context: NSManagedObjectContext) {
        self.action = action
        self.context = context
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = Subscription(subscriber: subscriber, context: context, action: action)
        subscriber.receive(subscription: subscription)
    }
}

public extension ASyncCoreDataManagerSavePublisher {
    class Subscription<S> where S: Subscriber, Failure == S.Failure, Output == S.Input {
        private var subscriber: S?
        private let action: ASyncCoreDataManagerPublisherAction
        private let context: NSManagedObjectContext

        init(subscriber: S, context: NSManagedObjectContext, action: @escaping ASyncCoreDataManagerPublisherAction) {
            self.subscriber = subscriber
            self.context = context
            self.action = action
        }
    }
}

extension ASyncCoreDataManagerSavePublisher.Subscription: Subscription {
    public func request(_ demand: Subscribers.Demand) {
        var demand = demand
        guard let subscriber, demand > 0 else {
            return
        }

        do {
            action()
            demand -= 1
            if context.hasChanges {
                try context.save()
            }
            demand += subscriber.receive(true)
        } catch {
            context.rollback()
            subscriber.receive(completion: .failure(error as NSError))
        }
    }
}

extension ASyncCoreDataManagerSavePublisher.Subscription: Cancellable {
    public func cancel() {
        subscriber = nil
    }
}
