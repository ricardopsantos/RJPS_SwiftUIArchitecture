//
//  CLLocationCoordinate2D+Extensions.swift
//  Common
//
//  Created by Ricardo Santos on 24/08/2024.
//

import Foundation
import MapKit

public extension CLLocationCoordinate2D {
    static var lisbon: Self {
        CLLocationCoordinate2D(latitude: 38.736946, longitude: -9.142685)
    }

    static var random: Self {
        random(in: 50_000, around: .lisbon) // 50km
    }

    static func random(
        in radius: Double = 50_000, // 50km
        around center: CLLocationCoordinate2D = .lisbon
    ) -> CLLocationCoordinate2D {
        let earthRadius = 6_371_000.0 // Earth radius in meters

        // Random angle in radians
        let angle = Double.random(in: 0..<2 * .pi)

        // Random distance in meters
        let distance = Double.random(in: 0..<radius)

        // Offsets in latitude and longitude
        let deltaLatitude = (distance / earthRadius) * (180 / .pi)
        let deltaLongitude = (distance / (earthRadius * cos(center.latitude * .pi / 180))) * (180 / .pi)

        // Calculate new coordinates
        let newLatitude = center.latitude + deltaLatitude * cos(angle)
        let newLongitude = center.longitude + deltaLongitude * sin(angle)

        return CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
    }

    static func regionToFitCoordinates(coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        coordinates.regionToFitCoordinates()
    }
}

public extension Array where Element == CLLocationCoordinate2D {
    func regionToFitCoordinates() -> MKCoordinateRegion {
        guard !isEmpty else {
            return MKCoordinateRegion()
        }

        var minLat = self[0].latitude
        var maxLat = self[0].latitude
        var minLon = self[0].longitude
        var maxLon = self[0].longitude

        for coordinate in self {
            minLat = Swift.min(minLat, coordinate.latitude)
            maxLat = Swift.max(maxLat, coordinate.latitude)
            minLon = Swift.min(minLon, coordinate.longitude)
            maxLon = Swift.max(maxLon, coordinate.longitude)
        }

        var latitudeDelta = maxLat - minLat
        var longitudeDelta = maxLon - minLon
        if latitudeDelta == 0 {
            latitudeDelta = 0.01
        }
        if longitudeDelta == 0 {
            longitudeDelta = 0.01
        }
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        return MKCoordinateRegion(center: center, span: span)
    }
}
