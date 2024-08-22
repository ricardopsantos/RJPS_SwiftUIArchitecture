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
    // MARK: - TrackedEntity
    //
    func trackedEntityInsertOrUpdate(trackedEntity: Model.TrackedEntity) -> String
    func trackedEntityInsert(trackedEntity: Model.TrackedEntity) -> String
    func trackedEntityUpdate(trackedEntity: Model.TrackedEntity) -> String
    func trackedEntityGet(trackedEntityId: String, cascade: Bool) -> Model.TrackedEntity?
    func trackedEntityGetAll(favorite: Bool?, archived: Bool?, cascade: Bool) -> [Model.TrackedEntity]
    func trackedEntityDelete(trackedEntityId: String)
    func trackedEntityDelete(trackedEntity: Model.TrackedEntity)
    func trackedEntityDeleteAll()
    //
    // MARK: - TrackedLog
    //
    func trackedLogInsertOrUpdate(trackedLog: Model.TrackedLog, trackedEntityId: String)
    func trackedLogGetAll(cascade: Bool) -> [Model.TrackedLog]
    func trackedLogGet(trackedEntityId: String?, cascade: Bool) -> [Model.TrackedLog]
    func trackedLogDelete(trackedLogId: String)
    func trackedLogDelete(trackedEntityId: String)
}
