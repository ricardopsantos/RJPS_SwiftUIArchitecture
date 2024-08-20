//
//  Created by Ricardo Santos on 13/08/2024.
//

import Foundation
import CoreData
import Combine

//
// MARK: - CRUDEntityDBRepository
//

public enum DataBaseRepositoryOutput: Hashable {
    public enum Generic: Hashable, Sendable {
        case databaseDidInsertedContentOn(_ dbModelName: String, id: String?) // Inserted record
        case databaseDidUpdatedContentOn(_ dbModelName: String, id: String?) // Updated record
        case databaseDidDeletedContentOn(_ dbModelName: String, id: String?) // Delete record
        case databaseDidChangedContentItemOn(_ dbModelName: String) // CRUD record
        case databaseDidFinishChangeContentItemsOn(_ dbModelName: String) // Any operation finish for records list
    }

    case generic(_ value: Generic)
}

public extension CommonCoreData.Utils.Sample {
    class DataBaseRepository: CommonCoreData.BaseCoreDataManager {
        public typealias OutputType = DataBaseRepositoryOutput
        public static var output = PassthroughSubject<OutputType, Never>()
        var fetchedResultsController: NSFetchedResultsController<CDataCRUDEntity>?
        public static var shared = DataBaseRepository(
            dbName: Common.internalDB,
            dbBundle: Common.bundleIdentifier
        )
        override private init(dbName: String, dbBundle: String) {
            super.init(dbName: dbName, dbBundle: dbBundle)
        }

        override func startFetchedResultsController() {
            guard fetchedResultsController == nil else {
                return
            }
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: CDataCRUDEntity.fetchRequestAll(sorted: true),
                managedObjectContext: viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            if let fetchedResultsController = fetchedResultsController {
                fetchedResultsController.delegate = self
            }

            // Perform the initial fetch
            try? fetchedResultsController?.performFetch()
        }
    }
}

//
// MARK: Events emission
//

public extension CommonCoreData.Utils.Sample.DataBaseRepository {
    func emit(event: OutputType) {
        Self.emit(event: event)
    }

    func output(_ filter: [OutputType] = []) -> AnyPublisher<OutputType, Never> {
        Self.output(filter)
    }

    static func emit(event: OutputType) {
        output.send(event)
    }

    static func output(_ filter: [OutputType] = []) -> AnyPublisher<OutputType, Never> {
        if filter.isEmpty {
            return output.eraseToAnyPublisher()
        } else {
            return output.filter { filter.contains($0) }.eraseToAnyPublisher()
        }
    }
}
