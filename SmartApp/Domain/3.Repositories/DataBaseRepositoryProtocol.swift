//
//  DataBaseRepositoryProtocol.swift
//  Domain
//
//  Created by Ricardo Santos on 22/08/2024.
//

import Foundation
import Combine
//
import Common

public protocol DataBaseRepositoryProtocol {
    //
    // MARK: - Database emissions
    //
    typealias OutputType = CommonBaseCoreDataManagerOutput
    func emit(event: OutputType)
    func output(_ filter: [OutputType]) -> AnyPublisher<OutputType, Never>
    static func emit(event: OutputType)
    static func output(_ filter: [OutputType]) -> AnyPublisher<OutputType, Never>
    //
    // MARK: - Utils
    //
    func initDataBase()

    //
    // MARK: - TrackedEntity
    //
    @discardableResult func trackedEntityInsertOrUpdate(trackedEntity: Model.TrackedEntity) -> String
    @discardableResult func trackedEntityInsert(trackedEntity: Model.TrackedEntity) -> String
    @discardableResult func trackedEntityUpdate(trackedEntity: Model.TrackedEntity) -> String
    @discardableResult func trackedEntityGet(trackedEntityId: String, cascade: Bool) -> Model.TrackedEntity?
    @discardableResult func trackedEntityGetAll(favorite: Bool?, archived: Bool?, cascade: Bool) -> [Model.TrackedEntity]
    func trackedEntityDelete(trackedEntityId: String)
    func trackedEntityDelete(trackedEntity: Model.TrackedEntity)
    func trackedEntityDeleteAll()
    //
    // MARK: - TrackedLog
    //
    func trackedLogGetAll(
        min: Date,
        maxDate: Date,
        cascade: Bool
    ) -> [Model.TrackedLog]
    func trackedLogGetAll(
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?,
        cascade: Bool
    ) -> [Model.TrackedLog]
    func trackedLogInsertOrUpdate(trackedLog: Model.TrackedLog, trackedEntityId: String)
    func trackedLogGetAll(cascade: Bool) -> [Model.TrackedLog]
    func trackedLogGet(trackedEntityId: String?, cascade: Bool) -> [Model.TrackedLog]
    func trackedLogGet(trackedLogId: String?, cascade: Bool) -> Model.TrackedLog?
    func trackedLogDelete(trackedLogId: String)
    func trackedLogDelete(trackedEntityId: String)
}
