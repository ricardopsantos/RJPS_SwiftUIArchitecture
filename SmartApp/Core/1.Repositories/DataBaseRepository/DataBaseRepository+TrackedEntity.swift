//
//  DataBaseRepository.swift
//  Core
//
//  Created by Ricardo Santos on 21/08/2024.
//

import Foundation
//
import Common
import Domain
import CoreData

public extension DataBaseRepository {
    //
    // MARK: - Insert/Update
    //
    func trackedEntityInsertOrUpdate(trackedEntity: Model.TrackedEntity) -> String {
        if trackedEntityGet(trackedEntityId: trackedEntity.id, cascade: false) == nil {
            trackedEntityInsert(trackedEntity: trackedEntity)
        } else {
            trackedEntityUpdate(trackedEntity: trackedEntity)
        }
    }

    func trackedEntityInsert(trackedEntity: Model.TrackedEntity) -> String {
        typealias DBEntity = CDataTrackedEntity
        let context = viewContext
        let some: DBEntity = DBEntity(context: context)
        some.id = UUID().uuidString
        some.bindWith(model: trackedEntity)
        if let cascadeEvents = trackedEntity.cascadeEvents, !cascadeEvents.isEmpty {
            // Add new events
            cascadeEvents.forEach { event in
                let trackedLog: CDataTrackedLog = CDataTrackedLog(context: context)
                trackedLog.id = UUID().uuidString
                trackedLog.bind(model: event)
                some.addToEvents(trackedLog)
            }
        }
        CommonCoreData.Utils.save(viewContext: context)
        return some.id?.description ?? ""
    }

    @discardableResult
    func trackedEntityUpdate(trackedEntity: Model.TrackedEntity) -> String {
        typealias DBEntity = CDataTrackedEntity
        let context = viewContext
        let instances = try? context.fetch(DBEntity.fetchRequestWith(id: trackedEntity.id))
        if let some = instances?.first {
            some.bindWith(model: trackedEntity)

            // Delete/update current events. We ONLY do this, if we have cascadeEvents != nil.
            // (We could have fetched the `TrackedEntity` without the `cascade` option just to
            // update one property. Dont remove the type/cast
            let canUpdateEvents = trackedEntity.cascadeEvents != nil
            if canUpdateEvents {
                var currentEventsId: [String] = []
                some.events?.forEach { event in
                    if let storedEvent = event as? CDataTrackedLog {
                        let relatedEvent = trackedEntity.cascadeEvents?.filter { $0.id == storedEvent.id }.first
                        let wasDeleted = relatedEvent == nil
                        if wasDeleted {
                            // Deleted
                            context.delete(event as! NSManagedObject)
                        } else if let relatedEvent = relatedEvent {
                            // Updated?
                            storedEvent.bind(model: relatedEvent)
                            currentEventsId.append(relatedEvent.id)
                        }
                    }
                }
                // Add new events
                if let cascadeEvents = trackedEntity.cascadeEvents, !cascadeEvents.isEmpty {
                    // Add new events
                    cascadeEvents.forEach { event in
                        let isNew = !currentEventsId.contains(event.id)
                        if isNew {
                            let trackedLog: CDataTrackedLog = CDataTrackedLog(context: context)
                            trackedLog.id = UUID().uuidString
                            trackedLog.bind(model: event)
                            some.addToEvents(trackedLog)
                        }
                    }
                }
            }

            CommonCoreData.Utils.save(viewContext: context)
            return trackedEntity.id
        } else {
            return ""
        }
    }

    //
    // MARK: - Get
    //

    func trackedEntityGet(trackedEntityId: String, cascade: Bool) -> Model.TrackedEntity? {
        typealias DBEntity = CDataTrackedEntity
        let context = viewContext
        let instances = try? context.fetch(DBEntity.fetchRequestWith(id: trackedEntityId))
        guard let existingEntity = instances?.first else {
            return nil
        }
        return existingEntity.mapToModel(cascade: cascade)
    }

    func trackedEntityGetAll(favorite: Bool? = nil, archived: Bool? = nil, cascade: Bool) -> [Model.TrackedEntity] {
        typealias DBEntity = CDataTrackedEntity
        let context = viewContext
        do {
            var results = try context.fetch(DBEntity.fetchRequest())
            if let favorite = favorite {
                results = results.filter { $0.favorite == favorite }
            }
            if let archived = archived {
                results = results.filter { $0.archived == archived }
            }
            return results.map { $0.mapToModel(cascade: cascade) }
        } catch {
            return []
        }
    }

    //
    // MARK: - Delete
    //

    func trackedEntityDelete(trackedEntityId: String) {
        typealias DBEntity = CDataTrackedEntity
        let context = viewContext
        let instances = try? context.fetch(DBEntity.fetchRequestWith(id: trackedEntityId))
        if let existingEntity = instances?.first {
            context.delete(existingEntity)
        }
        CommonCoreData.Utils.save(viewContext: context)
    }

    func trackedEntityDelete(trackedEntity: Model.TrackedEntity) {
        trackedEntityDelete(trackedEntityId: trackedEntity.id)
    }

    func trackedEntityDeleteAll() {
        trackedEntityGetAll(cascade: false).forEach { item in
            trackedEntityDelete(trackedEntity: item)
        }
    }
}
