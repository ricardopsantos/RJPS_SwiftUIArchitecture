//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData
import Combine

//
// MARK: - CommonBaseCoreDataManagerOutput
//

public enum CommonBaseCoreDataManagerOutput: Hashable {
    public enum Generic: Hashable, Sendable {
        case databaseDidInsertedContentOn(_ dbModelName: String, id: String?) // Inserted record
        case databaseDidUpdatedContentOn(_ dbModelName: String, id: String?) // Updated record
        case databaseDidDeletedContentOn(_ dbModelName: String, id: String?) // Delete record
        case databaseDidChangedContentItemOn(_ dbModelName: String) // CRUD record
        case databaseDidFinishChangeContentItemsOn(_ dbModelName: String) // Any operation finish for records list
    }
    
    case generic(_ value: Generic)
}

//
// MARK: - Events emission sugar
//

public extension CommonBaseCoreDataManager {
    typealias OutputType = CommonBaseCoreDataManagerOutput
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
