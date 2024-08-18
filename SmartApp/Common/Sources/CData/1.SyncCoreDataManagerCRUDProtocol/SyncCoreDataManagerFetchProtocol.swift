//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

//
// Just use anywhere earn the protocol extension behaviours
// Inspired on : https://medium.com/dev-genius/ios-core-data-with-sugar-syntax-ef53a0e06efe
//

private var mainQueueFetchDispatchSemaphore = DispatchSemaphore(value: 1)

public protocol SyncCoreDataManagerFetchProtocol {
    var viewContext: NSManagedObjectContext { get }
    var backgroundContext: NSManagedObjectContext { get }
    func fetch<T: NSManagedObject>(
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]?,
        limit: Int?,
        batchSize: Int?,
        fetchQueue: SyncCoreDataManagerOperationQueue
    ) -> [T]
    func fetch<T: NSManagedObject>(
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]?,
        limit: Int?,
        batchSize: Int?,
        context: NSManagedObjectContext?
    ) -> [T]
}

public extension SyncCoreDataManagerFetchProtocol {
    func fetch<T: NSManagedObject>(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int? = nil,
        batchSize: Int? = nil,
        context: NSManagedObjectContext?
    ) -> [T] {
        guard let context else { return [] }
        switch context.concurrencyType {
        case .privateQueueConcurrencyType:
            return fetchUsingPrivateQueue(
                predicate: predicate,
                sortDescriptors: sortDescriptors,
                limit: limit,
                batchSize: batchSize,
                backgroundContext: context
            )
        case .confinementConcurrencyType, .mainQueueConcurrencyType:
            return fetchUsingMainQueue(
                predicate: predicate,
                sortDescriptors: sortDescriptors,
                limit: limit,
                batchSize: batchSize,
                viewContext: context
            )
        @unknown default:
            return []
        }
    }

    func fetch<T: NSManagedObject>(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int? = nil,
        batchSize: Int? = nil,
        fetchQueue: SyncCoreDataManagerOperationQueue
    ) -> [T] {
        switch fetchQueue {
        case .mainQueue:
            fetchUsingMainQueue(
                predicate: predicate,
                sortDescriptors: sortDescriptors,
                limit: limit,
                batchSize: batchSize,
                viewContext: viewContext
            )
        case .privateQueue:
            fetchUsingPrivateQueue(
                predicate: predicate,
                sortDescriptors: sortDescriptors,
                limit: limit,
                batchSize: batchSize,
                backgroundContext: backgroundContext
            )
        }
    }

    func fetchUsingMainQueue<T: NSManagedObject>(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int? = nil,
        batchSize: Int? = nil,
        viewContext: NSManagedObjectContext
    ) -> [T] {
        _ = mainQueueFetchDispatchSemaphore.wait(timeout: .now() + 1)
        defer {
            mainQueueFetchDispatchSemaphore.signal()
        }
        let request = NSFetchRequest<T>(entityName: T.entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        if let limit, limit > 0 {
            request.fetchLimit = limit
        }
        if let batchSize, batchSize > 0 {
            request.fetchBatchSize = batchSize
        }
        do {
            return try viewContext.fetch(request)
        } catch {
            if Common_Utils.onDebug {
                fatalError("Couldn't fetch the entities for \(T.entityName) " + error.localizedDescription)
            } else {
                return []
            }
        }
    }

    func fetchUsingPrivateQueue<T: NSManagedObject>(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int? = nil,
        batchSize: Int? = nil,
        backgroundContext: NSManagedObjectContext
    ) -> [T] {
        var fetchedItems: [T] = []
        backgroundContext.performAndWait {
            let request = NSFetchRequest<T>(entityName: T.entityName)
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
            if let limit, limit > 0 {
                request.fetchLimit = limit
            }
            if let batchSize, batchSize > 0 {
                request.fetchBatchSize = batchSize
            }
            do {
                fetchedItems = try backgroundContext.fetch(request)
            } catch {
                fetchedItems = []
            }
        }
        return fetchedItems
    }
}
