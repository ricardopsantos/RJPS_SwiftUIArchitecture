//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

public protocol AsyncCoreDataManagerFetchProtocol {
    var viewContext: NSManagedObjectContext { get }
    func publisher<T: NSManagedObject>(fetch request: NSFetchRequest<T>) -> ASyncCoreDataManagerFetchPublisher<T>
}

public extension AsyncCoreDataManagerFetchProtocol {
    func publisher<T: NSManagedObject>(fetch request: NSFetchRequest<T>) -> ASyncCoreDataManagerFetchPublisher<T> {
        ASyncCoreDataManagerFetchPublisher(request: request, context: viewContext)
    }
}
