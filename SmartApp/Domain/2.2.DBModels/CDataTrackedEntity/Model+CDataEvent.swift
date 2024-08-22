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
    struct TrackedEntity: Equatable {
        public var id: String
        public var color: UIColor
        public var archived: Bool
        public var favorite: Bool
        public var category: HitHappensEventCategory
        public var sound: String
        public var cascadeEvents: [Model.TrackedLog]?
        public init(
            id: String,
            color: UIColor,
            archived: Bool,
            favorite: Bool,
            category: HitHappensEventCategory,
            sound: String,
            cascadeEvents: [Model.TrackedLog]?
        ) {
            self.id = id
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
            id: UUID().uuidString,
            color: UIColor.random,
            archived: Bool.random(),
            favorite: Bool.random(),
            category: .none,
            sound: "",
            cascadeEvents: cascadeEvents
        )
    }
}
