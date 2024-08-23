//
//  Created by Ricardo Santos on 14/08/2024.
//

import Foundation
import UIKit
//
import Common

//
// Mappers
//
public extension CDataTrackedEntity {
    /// DB -> Model
    func mapToModel(cascade: Bool) -> Model.TrackedEntity {
        var cascadeEvents: [Model.TrackedLog] = []
        if cascade, let list = events?.allObjects as? [CDataTrackedLog] {
            cascadeEvents = list.map { $0.mapToModel(cascade: false) }
        }
        return .init(
            id: id ?? "",
            name: name ?? "",
            info: info ?? "",
            archived: archived,
            favorite: favorite,
            locationRelevant: locationRelevant,
            category: .init(rawValue: Int(categoryId)) ?? .none,
            sound: SoundEffect(rawValue: sound ?? "") ?? .none,
            cascadeEvents: cascadeEvents
        )
    }

    /// Model -> DB
    func bindWith(model: Model.TrackedEntity) {
        name = model.name
        info = model.info
        archived = model.archived
        favorite = model.favorite
        categoryId = Int16(model.category.rawValue)
        locationRelevant = model.locationRelevant
        sound = model.sound.rawValue
    }
}
