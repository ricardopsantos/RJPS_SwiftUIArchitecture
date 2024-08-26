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
import Common
import DesignSystem
import Domain

// https://medium.com/@davidhu-sg/mapkit-in-swiftui-79bcea6b76fc

public extension GenericMapView {
    struct ModelItem: Identifiable {
        public let id: String
        public let name: String
        public let coordinate: CLLocationCoordinate2D
        public let onTap: () -> Void
        public let image: (
            systemName: String,
            backColor: Color,
            imageColor: Color
        )

        public init(
            id: String,
            name: String,
            coordinate: CLLocationCoordinate2D,
            onTap: @escaping () -> Void,
            image: (systemName: String, backColor: Color, imageColor: Color)
        ) {
            self.id = id
            self.name = name
            self.coordinate = coordinate
            self.onTap = onTap
            self.image = image
        }

        public init(
            id: String,
            name: String,
            coordinate: CLLocationCoordinate2D,
            onTap: @escaping () -> Void,
            category: HitHappensEventCategory
        ) {
            self.id = id
            self.name = name
            self.coordinate = coordinate
            self.onTap = onTap
            self.image = (
                category.systemImageName,
                ColorSemantic.backgroundPrimary.color,
                category.color
            )
        }

        static var random: Self {
            ModelItem(
                id: UUID().uuidString,
                name: String.random(10),
                coordinate: .random,
                onTap: {},
                category: .fitness
            )
        }
    }
}

public struct GenericMapView: View {
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0)
    )
    @Binding var items: [ModelItem]
    private let onRegionChanged: (MKCoordinateRegion)->()
    public init(items: Binding<[ModelItem]>, onRegionChanged: @escaping (MKCoordinateRegion)->()) {
        self.onRegionChanged = onRegionChanged
        self._items = items
    }

    public var body: some View {
        Map(coordinateRegion: $region, annotationItems: items) { item in
            MapAnnotation(coordinate: item.coordinate) {
                mapAnnotation(with: item)
            }
        }
        .onChange(of: region) { new in
            onRegionChanged(new)
        }
        .onAppear {
            region = items.map(\.coordinate).regionToFitCoordinates()
        }
    }
}

//
// MARK: - Auxiliar Views
//
public extension GenericMapView {
    @ViewBuilder
    func mapAnnotation(with item: ModelItem) -> some View {
        let margin: CGFloat = SizeNames.size_3.cgFloat
        let size: CGFloat = SizeNames.defaultMargin + margin
        Button(action: {
            item.onTap()
        }) {
            ListItemView.buildAccessoryImage(
                systemImage: item.image.systemName,
                imageColor: item.image.imageColor,
                margin: margin
            )
            .background(item.image.backColor.opacity(0.75))
        }
        .background(Color.clear)
        .cornerRadius2(size / 2)
        .frame(maxWidth: size, maxHeight: size)
        .id(item.id)
    }
}

//
// MARK: - Utils
//
public extension GenericMapView {}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    GenericMapView(items: .constant([.random]), onRegionChanged: { _ in })
}
#endif
