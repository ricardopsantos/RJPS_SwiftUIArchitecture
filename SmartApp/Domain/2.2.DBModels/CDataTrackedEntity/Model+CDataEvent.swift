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
        public var id: UUID
        public var name: String
        public var info: String
        public var color: UIColor
        public var archived: Bool
        public var favorite: Bool
        public var category: HitHappensEventCategory
        public var sound: String
        public var cascadeEvents: [Model.TrackedLog]?
        public init(
            id: UUID,
            name: String,
            info: String,
            color: UIColor,
            archived: Bool,
            favorite: Bool,
            category: HitHappensEventCategory,
            sound: String,
            cascadeEvents: [Model.TrackedLog]?
        ) {
            print("make id string")
            self.id = id
            self.name = name
            self.info = info
            self.color = color
            self.archived = archived
            self.favorite = favorite
            self.category = category
            self.sound = sound
            self.cascadeEvents = cascadeEvents
        }
    }
}

public extension Model.TrackedEntity {
    static func random(cascadeEvents: [Model.TrackedLog]) -> Self {
        Model.TrackedEntity(
            id: UUID(),
            name: String.randomWithSpaces(10),
            info: String.randomWithSpaces(10),
            color: UIColor.random,
            archived: false,
            favorite: true,
            category: .none,
            sound: "",
            cascadeEvents: cascadeEvents
        )
    }
}
