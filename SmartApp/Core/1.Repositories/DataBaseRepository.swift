//
//  DataBaseRepository.swift
//  Core
//
//  Created by Ricardo Santos on 21/08/2024.
//

import Foundation
import CoreData
import Combine
//
import Common
import Domain

//
// MARK: - CommonDataBaseRepository
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

public class DataBaseRepository: CommonCoreData.BaseCoreDataManager {
    public typealias OutputType = CommonDataBaseRepositoryOutput
    public static var output = PassthroughSubject<OutputType, Never>()
    private (set) var fetchedResultsControllerDic: [String: NSFetchedResultsController<NSManagedObject>] = [:]
    public static var shared = DataBaseRepository(
        dbName: Domain.internalDB,
        dbBundle: Domain.bundleIdentifier
    )
    override private init(dbName: String, dbBundle: String) {
        super.init(dbName: dbName, dbBundle: dbBundle)
    }

    override func startFetchedResultsController() {
        guard fetchedResultsControllerDic.count == 0 else {
            return
        }
        
        // Create the controller with specific type
        fetchedResultsControllerDic["\(CDataCRUDEntity.self)"] = NSFetchedResultsController<NSManagedObject>(
            fetchRequest: CDataCRUDEntity.fetchRequestAll(sorted: true) as! NSFetchRequest<NSManagedObject>,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsControllerDic["\(CDataSinger.self)"] = NSFetchedResultsController<NSManagedObject>(
            fetchRequest: CDataSinger.fetchRequestAll(sorted: true) as! NSFetchRequest<NSManagedObject>,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsControllerDic["\(CDataSong.self)"] = NSFetchedResultsController<NSManagedObject>(
            fetchRequest: CDataSong.fetchRequestAll(sorted: true) as! NSFetchRequest<NSManagedObject>,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsControllerDic.forEach({ (_, controller) in
            controller.delegate = self
            try? controller.performFetch()
        })
        
    }
}

//
// MARK: Events emission
//

public extension CommonDataBaseRepository {
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
