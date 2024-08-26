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
import DevTools

public extension DataBaseRepository {
    //
    // MARK: - Insert/Update
    //

    func trackedLogInsertOrUpdate(trackedLog: Model.TrackedLog, trackedEntityId: String) {
        typealias DBEntity = CDataTrackedLog
        let context = viewContext
        do {
            guard let parent = try context.fetch(
                CDataTrackedEntity
                    .fetchRequestWith(id: trackedEntityId)
            ).first else {
                DevTools.Log.error("Parent not found", .business)
                return
            }
            let stored: DBEntity? = try context.fetch(DBEntity.fetchRequestWith(id: trackedLog.id)).first
            if stored == nil {
                // Insert
                let some: DBEntity = DBEntity(context: context)
                some.id = UUID().uuidString
                some.bind(model: trackedLog)
                some.relationship = parent
            } else {
                stored?.bind(model: trackedLog)
            }
            CommonCoreData.Utils.save(viewContext: context)
        } catch {}
    }

    //
    // MARK: - Get
    //
    func trackedLogGetAll(cascade: Bool) -> [Model.TrackedLog] {
        trackedLogGet(trackedEntityId: nil, cascade: cascade)
    }

    func trackedLogGet(trackedLogId: String?, cascade: Bool) -> Model.TrackedLog? {
        guard let trackedLogId = trackedLogId, !trackedLogId.isEmpty else {
            return nil
        }
        typealias DBEntity = CDataTrackedLog
        let context = viewContext
        return try? context.fetch(DBEntity.fetchRequestWith(id: trackedLogId)).first?.mapToModel(cascade: cascade)
    }

    func trackedLogGetAll(
        min: Date,
        maxDate: Date,
        cascade: Bool
    ) -> [Model.TrackedLog] {
        typealias DBEntity = CDataTrackedLog
        let context = viewContext

        let fetchRequest = DBEntity.fetchRequest()
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "recordDate >= %@ AND recordDate <= %@", min as NSDate, maxDate as NSDate))
        if !predicates.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        let instances = try? context.fetch(fetchRequest)
        guard let entities = instances else {
            return []
        }
        return entities.map { $0.mapToModel(cascade: cascade) }
    }

    func trackedLogGetAll(
        minLatitude: Double? = nil,
        maxLatitude: Double? = nil,
        minLongitude: Double? = nil,
        maxLongitude: Double? = nil,
        date: Date? = nil,
        cascade: Bool
    ) -> [Model.TrackedLog] {
        typealias DBEntity = CDataTrackedLog
        let context = viewContext

        let fetchRequest = DBEntity.fetchRequest()
        var predicates: [NSPredicate] = []
        if let minLatitude = minLatitude {
            predicates.append(NSPredicate(format: "latitude >= %f", minLatitude))
        }
        if let maxLatitude = maxLatitude {
            predicates.append(NSPredicate(format: "latitude <= %f", maxLatitude))
        }
        if let minLongitude = minLongitude {
            predicates.append(NSPredicate(format: "longitude >= %f", minLongitude))
        }
        if let maxLongitude = maxLongitude {
            predicates.append(NSPredicate(format: "longitude <= %f", maxLongitude))
        }
        if let date = date {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            var dateComponents = DateComponents()
            dateComponents.day = 1
            dateComponents.second = -1
            let endOfDay = calendar.date(byAdding: dateComponents, to: startOfDay)!

            predicates.append(NSPredicate(format: "recordDate >= %@ AND recordDate <= %@", startOfDay as NSDate, endOfDay as NSDate))
        }
        if !predicates.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        let instances = try? context.fetch(fetchRequest)
        guard let entities = instances else {
            return []
        }
        return entities.map { $0.mapToModel(cascade: cascade) }
    }

    func trackedLogGet(trackedEntityId: String?, cascade: Bool) -> [Model.TrackedLog] {
        typealias DBEntity = CDataTrackedLog
        let context = viewContext
        do {
            if let trackedEntityId = trackedEntityId, !trackedEntityId.isEmpty {
                let fetchRequest1 = CDataTrackedEntity.fetchRequestWith(id: trackedEntityId)
                let trackedEntity: CDataTrackedEntity? = try context.fetch(fetchRequest1).first
                guard let trackedEntity = trackedEntity else {
                    return []
                }
                let fetchRequest2 = DBEntity.fetchRequestWith(relationship: trackedEntity)
                return try context.fetch(fetchRequest2).map { $0.mapToModel(cascade: cascade) }
            } else {
                // All records
                return try context.fetch(DBEntity.fetchRequest()).map { $0.mapToModel(cascade: cascade) }
            }
        } catch {
            return []
        }
    }

    //
    // MARK: - Delete
    //

    func trackedLogDelete(trackedLogId: String) {
        let context = viewContext
        do {
            let records: [CDataTrackedLog] = try context.fetch(
                CDataTrackedLog.fetchRequestWith(id: trackedLogId)
            )
            records.forEach { record in
                context.delete(record)
            }
            CommonCoreData.Utils.save(viewContext: context)
        } catch {}
    }

    func trackedLogDelete(trackedEntityId: String) {
        let records = trackedLogGet(trackedEntityId: trackedEntityId, cascade: false)
        records.forEach { record in
            trackedLogDelete(trackedLogId: record.id)
        }
    }
}
