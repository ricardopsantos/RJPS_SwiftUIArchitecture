//
//  Created by Ricardo Santos on 13/08/2024.
//

import Foundation

public extension CommonCoreData.Utils.Sample {
    struct CRUDEntity: Equatable {
        public let id: String
        public var name: String
        public var recordDate: Date
        public init(id: String, name: String, recordDate: Date) {
            self.id = id
            self.name = name
            self.recordDate = recordDate
        }
    }
}

public extension CommonCoreData.Utils.Sample.CRUDEntity {
    static var random: Self {
        Self(
            id: UUID().uuidString,
            name: "Joe \(String.randomWithSpaces(10))",
            recordDate: Date()
        )
    }
}
