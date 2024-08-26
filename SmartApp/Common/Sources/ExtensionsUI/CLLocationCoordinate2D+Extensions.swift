//
//  CLLocationCoordinate2D+Extensions.swift
//  Common
//
//  Created by Ricardo Santos on 24/08/2024.
//

import Foundation
import MapKit

public extension CLLocationCoordinate2D {
    static var lisbon: Self { CLLocationCoordinate2D(latitude: 38.736946, longitude: -9.142685) }
    static var london: Self { CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275) }
    static var paris: Self { CLLocationCoordinate2D(latitude: 48.856613, longitude: 2.352222) }
    static var berlin: Self { CLLocationCoordinate2D(latitude: 52.52, longitude: 13.405) }
    static var madrid: Self { CLLocationCoordinate2D(latitude: 40.416775, longitude: -3.70379) }
    static var rome: Self { CLLocationCoordinate2D(latitude: 41.902782, longitude: 12.496366) }
    static var amsterdam: Self { CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041) }
    static var brussels: Self { CLLocationCoordinate2D(latitude: 50.850346, longitude: 4.351721) }
    static var vienna: Self { CLLocationCoordinate2D(latitude: 48.208174, longitude: 16.373819) }
    static var stockholm: Self { CLLocationCoordinate2D(latitude: 59.329323, longitude: 18.068581) }
    static var copenhagen: Self { CLLocationCoordinate2D(latitude: 55.676098, longitude: 12.568337) }
    static var athens: Self { CLLocationCoordinate2D(latitude: 37.98381, longitude: 23.727539) }
    static var dublin: Self { CLLocationCoordinate2D(latitude: 53.349805, longitude: -6.26031) }
    static var helsinki: Self { CLLocationCoordinate2D(latitude: 60.169856, longitude: 24.938379) }
    static var oslo: Self { CLLocationCoordinate2D(latitude: 59.913869, longitude: 10.752245) }
    static var warsaw: Self { CLLocationCoordinate2D(latitude: 52.229676, longitude: 21.012229) }
    static var prague: Self { CLLocationCoordinate2D(latitude: 50.075538, longitude: 14.4378) }
    static var budapest: Self { CLLocationCoordinate2D(latitude: 47.497912, longitude: 19.040235) }
    static var bucharest: Self { CLLocationCoordinate2D(latitude: 44.426767, longitude: 26.102538) }
    static var sofia: Self { CLLocationCoordinate2D(latitude: 42.697708, longitude: 23.321868) }
    static var moscow: Self { CLLocationCoordinate2D(latitude: 55.755826, longitude: 37.6173) }
    static var kyiv: Self { CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234) }
    static var zurich: Self { CLLocationCoordinate2D(latitude: 47.376887, longitude: 8.541694) }

    static var europeanCapitals: [CLLocationCoordinate2D] {
        [
            .lisbon,
            .london,
            .paris,
            .berlin,
            .madrid,
            .rome,
            .amsterdam,
            .brussels,
            .vienna,
            .stockholm,
            .copenhagen,
            .athens,
            .dublin,
            .helsinki,
            .oslo,
            .warsaw,
            .prague,
            .budapest,
            .bucharest,
            .sofia,
            .moscow,
            .kyiv,
            .zurich
        ]
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
            latitudeDelta = 0.3
        }
        if longitudeDelta == 0 {
            longitudeDelta = 0.3
        }
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        return MKCoordinateRegion(center: center, span: span)
    }
}
