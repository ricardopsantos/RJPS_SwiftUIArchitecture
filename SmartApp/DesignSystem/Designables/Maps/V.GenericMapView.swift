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
    @State private var userLocation: CLLocationCoordinate2D?
    @State var shouldDisplayUserLocation: Bool = true
    @State var shouldDisplayEventsLocation: Bool = false
    @StateObject var locationViewModel: Common.SharedLocationManagerViewModel = .shared
    @State private var isUserInteracting = false
    private let onRegionChanged: (MKCoordinateRegion) -> Void
    public init(items: Binding<[ModelItem]>, onRegionChanged: @escaping (MKCoordinateRegion) -> Void) {
        self.onRegionChanged = onRegionChanged
        self._items = items
    }

    public var body: some View {
        content
            .onAppear {
                locationViewModel.start(sender: "\(Self.self)")
                shouldDisplayUserLocation = locationViewModel.locationIsAuthorized
                updateRegionToFitCoordinates()
            }.onDisappear {
                locationViewModel.stop(sender: "\(Self.self)")
            }
            .onChange(of: items) { _ in
                if shouldDisplayEventsLocation, items.isEmpty {
                    // No items, so no need on this being on
                    shouldDisplayEventsLocation = false
                }
            }
            .onChange(of: region) { new in
                onRegionChanged(new)
                if isUserInteracting {
                    // User changed region. Turn off action buttons
                    shouldDisplayUserLocation = false
                    shouldDisplayEventsLocation = false
                }
            }
            .onChange(of: locationViewModel.coordinates) { location in
                if let location = location {
                    userLocation = .init(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                    if shouldDisplayUserLocation, !shouldDisplayEventsLocation {
                        // Just displaying user and user changed location. Update region
                        withAnimation {
                            updateRegionToFitCoordinates()
                        }
                    }
                }
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
                annotationView(with: item)
            }
        }.gesture(
            DragGesture()
                .onChanged { _ in
                    isUserInteracting = true
                }
                .onEnded { _ in
                    isUserInteracting = false
                }
        )
    }

    @ViewBuilder
    public var actionBottonView: some View {
        let allEventsRegion = Button(action: {
            shouldDisplayEventsLocation.toggle()
            withAnimation {
                updateRegionToFitCoordinates()
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
        .userInteractionEnabled(!items.isEmpty)
        .paddingBottom(SizeNames.defaultMargin)
        .paddingRight(SizeNames.defaultMargin)
        let userRegion = Button(action: {
            shouldDisplayUserLocation.toggle()
            withAnimation {
                updateRegionToFitCoordinates()
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
        .userInteractionEnabled(locationViewModel.locationIsAuthorized)
        .paddingRight(SizeNames.defaultMargin)
        .paddingBottom(SizeNames.defaultMargin)
        HStack(spacing: 0) {
            Spacer()
            VStack(alignment: .leading, spacing: 0, content: {
                Spacer()
                allEventsRegion
                if locationViewModel.locationIsAuthorized {
                    userRegion
                }
            })
        }
    }
}

//
// MARK: - Auxiliar Views
//
public extension GenericMapView {
    @ViewBuilder
    func annotationView(with item: ModelItem) -> some View {
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
// MARK: - Auxiliar
//
public extension GenericMapView {
    var failSafeUserLocation: CLLocationCoordinate2D? {
        if let userLocation = userLocation {
            return userLocation
        } else if let coordinates = locationViewModel.coordinates {
            return .init(latitude: coordinates.latitude, longitude: coordinates.longitude)
        }
        return nil
    }

    func updateRegionToFitCoordinates() {
        guard shouldDisplayUserLocation || shouldDisplayEventsLocation else {
            return
        }
        var meanFullCoordinates: [CLLocationCoordinate2D] = []
        if shouldDisplayUserLocation,
           locationViewModel.locationIsAuthorized,
           let userLocation = failSafeUserLocation {
            meanFullCoordinates.append(userLocation)
        }
        if shouldDisplayEventsLocation {
            let validItems = items.map(\.coordinate)
                .filter { $0.latitude != 0 && $0.longitude != 0 }
            meanFullCoordinates.append(contentsOf: validItems)
        }
        if !meanFullCoordinates.isEmpty {
            region = meanFullCoordinates.regionToFitCoordinates()
        } else {
            // No coordinates! Center on user...
            if let userLocation = failSafeUserLocation {
                region = [userLocation].regionToFitCoordinates()
            } else if region.center.latitude == 0, region.center.longitude == 0 {
                // No coordinates and we failed to get the user position.
                // If we arrive here and the center of the map is on the ocean, center it on Europe
                region = CLLocationCoordinate2D.europeanCapitals.regionToFitCoordinates()
            }
        }
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
    VStack {
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
            .frame(maxHeight: screenHeight / 3)
        Spacer()
    }
    .padding()
}
#endif
