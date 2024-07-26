//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Combine
import CoreData

public struct ASyncCoreDataManagerDeletePublisher<Entity>: Publisher where Entity: NSManagedObject {
    public typealias Output = NSBatchDeleteResult
    public typealias Failure = NSError

    private let request: NSFetchRequest<Entity>
    private let context: NSManagedObjectContext

    init(delete request: NSFetchRequest<Entity>, context: NSManagedObjectContext) {
        self.request = request
        self.context = context
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = Subscription(subscriber: subscriber, context: context, request: request)
        subscriber.receive(subscription: subscription)
    }
}

public extension ASyncCoreDataManagerDeletePublisher {
    class Subscription<S> where S: Subscriber, Failure == S.Failure, Output == S.Input {
        private var subscriber: S?
        private let request: NSFetchRequest<Entity>
        private var context: NSManagedObjectContext

        init(subscriber: S, context: NSManagedObjectContext, request: NSFetchRequest<Entity>) {
            self.subscriber = subscriber
            self.context = context
            self.request = request
        }
    }
}

extension ASyncCoreDataManagerDeletePublisher.Subscription: Subscription {
    public func request(_ demand: Subscribers.Demand) {
        var demand = demand
        guard let subscriber, demand > 0 else {
            return
        }

        do {
            demand -= 1
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.entityName)
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            batchDeleteRequest.resultType = .resultTypeCount

            if let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult {
                demand += subscriber.receive(result)
            } else {
                subscriber.receive(completion: .failure(NSError()))
            }

        } catch {
            subscriber.receive(completion: .failure(error as NSError))
        }
    }
}

extension ASyncCoreDataManagerDeletePublisher.Subscription: Cancellable {
    public func cancel() {
        subscriber = nil
    }
}
