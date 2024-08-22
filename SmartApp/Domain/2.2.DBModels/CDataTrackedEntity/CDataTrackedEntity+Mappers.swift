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
            color: UIColor.colorFromRGBString(color ?? ""),
            archived: archived,
            favorite: favorite,
            category: .init(rawValue: Int(categoryId)) ?? .none,
            sound: sound ?? "",
            cascadeEvents: cascadeEvents
        )
    }

    /// Model -> DB
    func bindWith(model: Model.TrackedEntity) {
        color = model.color.rgbString
        archived = model.archived
        favorite = model.favorite
        categoryId = Int16(model.category.rawValue)
        sound = model.sound
    }
}
