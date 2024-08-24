//
//  TrackedEntity.swift
//  Core
//
//  Created by Ricardo Santos on 21/08/2024.
//

import Foundation
import UIKit
//
import Common

public extension Model {
    struct TrackedEntity: Equatable, Hashable, Identifiable, Sendable {
        public var id: String
        public var name: String
        public var info: String
        public var archived: Bool
        public var favorite: Bool
        public var autoPresentLog: Bool
        public var locationRelevant: Bool
        public var category: HitHappensEventCategory
        public var sound: SoundEffect
        public var cascadeEvents: [Model.TrackedLog]?
        public init(
            id: String,
            name: String,
            info: String,
            archived: Bool,
            favorite: Bool,
            autoPresentLog: Bool,
            locationRelevant: Bool,
            category: HitHappensEventCategory,
            sound: SoundEffect,
            cascadeEvents: [Model.TrackedLog]?
        ) {
            self.id = id
            self.name = name
            self.info = info
            self.locationRelevant = locationRelevant
            self.archived = archived
            self.favorite = favorite
            self.category = category
            self.sound = sound
            self.cascadeEvents = cascadeEvents
            self.autoPresentLog = autoPresentLog
        }
    }
}

public extension Model.TrackedEntity {
    static func random(cascadeEvents: [Model.TrackedLog]) -> Self {
        Model.TrackedEntity(
            id: UUID().uuidString,
            name: String.randomWithSpaces(10),
            info: String.randomWithSpaces(20),
            archived: Bool.random(),
            favorite: Bool.random(),
            autoPresentLog: true,
            locationRelevant: Bool.random(),
            category: .none,
            sound: .incorrect,
            cascadeEvents: cascadeEvents
        )
    }
}
