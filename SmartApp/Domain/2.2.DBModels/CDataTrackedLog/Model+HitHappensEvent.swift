//
//  HitHappensEvent.swift
//  Core
//
//  Created by Ricardo Santos on 21/08/2024.
//

import Foundation
import UIKit
//
import Common

public extension Model {
    struct TrackedLog: Equatable, Hashable, Sendable, Identifiable {
        public var id: String
        public var latitude: Double
        public var longitude: Double
        public var addressMin: String
        public var note: String
        public var recordDate: Date
        public var cascadeEntity: Model.TrackedEntity?

        public init(
            id: String = "",
            latitude: Double,
            longitude: Double,
            addressMin: String,
            note: String,
            recordDate: Date = .now,
            cascadeEntity: Model.TrackedEntity? = nil
        ) {
            self.id = id
            self.addressMin = addressMin
            self.latitude = latitude
            self.longitude = longitude
            self.note = note
            self.recordDate = recordDate
            self.cascadeEntity = cascadeEntity
        }
    }
}

public extension Model.TrackedLog {
    static var random: Self {
        Model.TrackedLog(
            id: UUID().uuidString,
            latitude: 0,
            longitude: 0,
            addressMin: "Address " + String.randomWithSpaces(10),
            note: String.randomWithSpaces(10),
            recordDate: Date.now,
            cascadeEntity: nil
        )
    }
}
