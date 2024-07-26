//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

public protocol AsyncCoreDataManagerDeleteProtocol {
    var viewContext: NSManagedObjectContext { get }
    func publisher<T: NSManagedObject>(delete request: NSFetchRequest<T>) -> ASyncCoreDataManagerDeletePublisher<T>
}

public extension AsyncCoreDataManagerDeleteProtocol {
    func publisher<T: NSManagedObject>(delete request: NSFetchRequest<T>) -> ASyncCoreDataManagerDeletePublisher<T> {
        ASyncCoreDataManagerDeletePublisher(delete: request, context: viewContext)
    }
}
