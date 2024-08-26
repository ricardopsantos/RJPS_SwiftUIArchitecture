//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import Foundation
import SwiftUI
import Combine
import MapKit
import CoreLocation
//
import DesignSystem
import Common
import Domain

public extension GenericMapView.ModelItem {
    static func with(
        trackedLog: Model.TrackedLog,
        onTap: @escaping () -> Void
    ) -> GenericMapView.ModelItem {
        let cascadeEntity = trackedLog.cascadeEntity!
        return .init(
            id: trackedLog.id,
            name: cascadeEntity.name,
            coordinate: .init(latitude: trackedLog.latitude, longitude: trackedLog.longitude),
            onTap: onTap,
            image: (
                cascadeEntity.category.systemImageName,
                ColorSemantic.backgroundPrimary.color,
                cascadeEntity.category.color
            )
        )
    }

    static func with(
        id: String,
        name: String,
        coordinate: CLLocationCoordinate2D,
        onTap: @escaping () -> Void,
        category: HitHappensEventCategory
    ) -> GenericMapView.ModelItem {
        .init(
            id: id,
            name: name,
            coordinate: coordinate,
            onTap: onTap,
            image: (
                category.systemImageName,
                ColorSemantic.backgroundPrimary.color,
                category.color
            )
        )
    }

    static var random: Self {
        .with(
            id: UUID().uuidString,
            name: String.random(10),
            coordinate: .random,
            onTap: {},
            category: .fitness
        )
    }
}
