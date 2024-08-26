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
    }
}

public struct GenericMapView: View {
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0)
    )
    @Binding var items: [ModelItem]
    private let onRegionChanged: (MKCoordinateRegion) -> Void
    @State private var userTrackingMode: MKUserTrackingMode = .follow
    @State private var userLocation: CLLocationCoordinate2D?
    @StateObject var locationViewModel: Common.CoreLocationManagerViewModel = .shared

    public init(items: Binding<[ModelItem]>, onRegionChanged: @escaping (MKCoordinateRegion) -> Void) {
        self.onRegionChanged = onRegionChanged
        self._items = items
    }

    public var body: some View {
        context
        .onChange(of: region) { new in
            onRegionChanged(new)
        }
        .onChange(of: locationViewModel.coordinates) { coordinates in
            if let coordinates = coordinates {
                userLocation = .init(latitude: coordinates.latitude,
                                     longitude: coordinates.longitude)
            } else {
                userLocation = nil
            }
        }
        .onAppear {
            locationViewModel.start()
            if !items.isEmpty {
                region = items.map(\.coordinate).regionToFitCoordinates()
            } else if let lastKnowLocation = Common.CoreLocationManager.shared.lastKnowLocation {
                region = MKCoordinateRegion(
                    center: .init(
                        latitude: lastKnowLocation.location.coordinate.latitude,
                        longitude: lastKnowLocation.location.coordinate.longitude
                    ),
                    span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
                )
            }
        }.onDisappear {
            locationViewModel.stop()
        }
    }
    
    public var context: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: items) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    mapAnnotation(with: item)
                }
            }
            .shadow(radius: SizeNames.shadowRadiusRegular)
            .cornerRadius2(SizeNames.cornerRadius)
            // New: Add button to recenter map to user's location
            VStack(spacing: 0) {
                Spacer()
                HStack(spacing: 0) {
                    Spacer()
                    Button(action: {
                        if let userLocation = userLocation {
                            region.center = userLocation
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .padding(SizeNames.size_3.cgFloat)
                            .background(ColorSemantic.primary.color.opacity(0.7))
                            .clipShape(Circle())
                            .foregroundColor(.white)
                            .shadow(radius: SizeNames.shadowRadiusRegular)
                    }
                    .paddingRight(SizeNames.defaultMargin)
                    .paddingBottom(SizeNames.defaultMargin)
                }
            }
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
    GenericMapView(items: .constant([.init(
        id: "",
        name: "",
        coordinate: .random,
        onTap: {},
        image: ("heart", .random, .random)
    )]), onRegionChanged: { _ in })
    .padding()
}
#endif
