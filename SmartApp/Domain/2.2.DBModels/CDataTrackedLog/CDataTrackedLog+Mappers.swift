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
public extension CDataTrackedLog {
    /// DB -> Model
    func mapToModel(cascade: Bool) -> Model.TrackedLog {
        var cascadeEntity: Model.TrackedEntity?
        if cascade, let relationship = relationship {
            cascadeEntity = relationship.mapToModel(cascade: false)
        }
        return .init(
            id: id ?? "",
            latitude: latitude,
            longitude: longitude,
            note: note ?? "",
            recordDate: recordDate ?? .now,
            cascadeEntity: cascadeEntity
        )
    }

    /// Model -> DB
    func bind(model: Model.TrackedLog) {
        latitude = model.latitude
        longitude = model.longitude
        note = model.note
        recordDate = model.recordDate
    }
}
