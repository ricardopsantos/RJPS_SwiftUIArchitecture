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
    struct ModelItem: Identifiable, Equatable {
        public static func == (lhs: GenericMapView.ModelItem, rhs: GenericMapView.ModelItem) -> Bool {
            lhs.id == rhs.id &&
                lhs.name == rhs.name &&
                lhs.coordinate.latitude == rhs.coordinate.latitude &&
                lhs.coordinate.longitude == rhs.coordinate.longitude &&
                lhs.image.systemName == rhs.image.systemName &&
                lhs.image.backColor == rhs.image.backColor &&
                lhs.image.imageColor == rhs.image.imageColor
        }

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
    @State private var userTrackingMode: MKUserTrackingMode = .follow
    @State private var userLocation: CLLocationCoordinate2D?
    @State var shouldDisplayUserLocation: Bool = false
    @State var shouldDisplayEventsLocation: Bool = true
    @StateObject var locationViewModel: Common.SharedLocationManagerViewModel = .shared
    private let onRegionChanged: (MKCoordinateRegion) -> Void
    public init(items: Binding<[ModelItem]>, onRegionChanged: @escaping (MKCoordinateRegion) -> Void) {
        self.onRegionChanged = onRegionChanged
        self._items = items
    }

    public var body: some View {
        content
            .onChange(of: items) { _ in
                //    updateRegion()
            }
            .onChange(of: region) { new in
                onRegionChanged(new)
            }
            .onChange(of: locationViewModel.coordinates) { location in
                if let location = location {
                    userLocation = .init(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                } else {
                    userLocation = nil
                }
            }
            .onAppear {
                locationViewModel.start()
                Common_Utils.delay {
                    updateRegion()
                }
            }.onDisappear {
                locationViewModel.stop()
            }
    }

    public var content: some View {
        ZStack {
            mapView
            actionBottonView
        }.cornerRadius2(SizeNames.cornerRadius)
    }

    public var mapView: some View {
        Map(coordinateRegion: $region, annotationItems: items) { item in
            MapAnnotation(coordinate: item.coordinate) {
                mapAnnotation(with: item)
            }
        }
    }

    public var actionBottonView: some View {
        // New: Add button to recenter map on available points
        HStack {
            Spacer()
            VStack(alignment: .leading, spacing: 0, content: {
                Spacer()
                Button(action: {
                    withAnimation {
                        shouldDisplayEventsLocation.toggle()
                        updateRegion()
                    }
                }) {
                    Image(systemName: "list.bullet")
                        .frame(SizeNames.defaultMargin)
                        .padding(SizeNames.size_3.cgFloat)
                        .doIf(shouldDisplayEventsLocation, transform: {
                            $0.background(ColorSemantic.primary.color.opacity(1))
                        })
                        .doIf(!shouldDisplayEventsLocation, transform: {
                            $0.background(ColorSemantic.backgroundTertiary.color.opacity(0.66))
                        })
                        .clipShape(Circle())
                        .foregroundColor(.white)
                        .shadow(radius: SizeNames.shadowRadiusRegular)
                }
                .paddingBottom(SizeNames.defaultMargin)
                .paddingRight(SizeNames.defaultMargin)
                Button(action: {
                    withAnimation {
                        shouldDisplayUserLocation.toggle()
                        updateRegion()
                    }
                }) {
                    Image(systemName: "location.fill")
                        .frame(SizeNames.defaultMargin)
                        .padding(SizeNames.size_3.cgFloat)
                        .doIf(shouldDisplayUserLocation, transform: {
                            $0.background(ColorSemantic.primary.color.opacity(1))
                        })
                        .doIf(!shouldDisplayUserLocation, transform: {
                            $0.background(ColorSemantic.backgroundTertiary.color.opacity(0.66))
                        })
                        .clipShape(Circle())
                        .foregroundColor(.white)
                        .shadow(radius: SizeNames.shadowRadiusRegular)
                }
                .paddingRight(SizeNames.defaultMargin)
                .paddingBottom(SizeNames.defaultMargin)
            })
        }
    }
}

//
// MARK: - Auxiliar
//
public extension GenericMapView {
    func updateRegion() {
        var coordinates: [CLLocationCoordinate2D] = []
        if shouldDisplayUserLocation, let userLocation = userLocation {
            coordinates.append(userLocation)
        }
        if shouldDisplayEventsLocation {
            let validItems = items.map(\.coordinate)
                .filter { $0.latitude != 0 && $0.longitude != 0 }
            coordinates.append(contentsOf: validItems)
        }
        if !coordinates.isEmpty {
            region = coordinates.regionToFitCoordinates()
        } else {
            // No coordinates! Center on user...
            if let userLocation {
                region = [userLocation].regionToFitCoordinates()
            } else {
                region = CLLocationCoordinate2D.europeanCapitals.regionToFitCoordinates()
            }
        }
    }

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
    GenericMapView(items: .constant([
        .init(
            id: "",
            name: "1",
            coordinate: .random,
            onTap: {},
            image: ("heart", .random, .random)
        ),
        .init(
            id: "",
            name: "2",
            coordinate: .random,
            onTap: {},
            image: ("heart", .random, .random)
        ),
        .init(
            id: "",
            name: "3",
            coordinate: .random,
            onTap: {},
            image: ("heart", .random, .random)
        )
    ]), onRegionChanged: { _ in })
        .padding()
}
#endif
