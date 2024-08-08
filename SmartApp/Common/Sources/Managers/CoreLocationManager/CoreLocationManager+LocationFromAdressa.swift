//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreLocation
import Combine

//
// MARK: - Utils (LocationFromAdress)
//

public extension Common.CoreLocationManager {
    static func cachedLocationFromAddressClean() {
        let defaults = cachedLocationFromAddress
        let dictionary = defaults?.dictionaryRepresentation()
        dictionary?.keys.forEach { key in
            defaults?.removeObject(forKey: key)
        }
        defaults?.synchronize()
    }

    private static var cachedLocationFromAddress: UserDefaults? {
        UserDefaults(suiteName: "\(Self.self).cache.LocationFromAddress")
    }

    struct LocationForAddress: Codable {
        public let latitude: Double
        public let longitude: Double
        public let addressIn: String
        public let addressOut: String
    }

    static func locationFromAddress(_ address: String) async throws -> LocationForAddress? {
        let result: LocationForAddress? = try await withCheckedThrowingContinuation { continuation in
            locationFromAddress(address) { locationForAddress in
                continuation.resume(with: .success(locationForAddress))
            }
        }
        return result
    }

    static func locationFromAddress(_ address: String) -> AnyPublisher<LocationForAddress?, Never> {
        Future { promise in
            locationFromAddress(address) { result in
                promise(.success(result))
            }
        }.eraseToAnyPublisher()
    }

    private static func locationFromAddress(_ address: String, completion: @escaping (LocationForAddress?) -> Void) {
        let addressEscaped = address.trim.lowercased()
        guard !addressEscaped.isEmpty else {
            completion(nil)
            return
        }
        let cacheKey = "\(Self.self)_\(#function)_cacheFor:\(addressEscaped)"
        if let data = cachedLocationFromAddress?.data(forKey: cacheKey),
           let locationForAddress = try? JSONDecoder().decodeFriendly(LocationForAddress.self, from: data) {
            completion(locationForAddress)
            return
        }

        guard Common_Utils.existsInternetConnection else {
            completion(nil)
            return
        }
        let ceo: CLGeocoder = CLGeocoder()
        ceo.geocodeAddressString(addressEscaped, completionHandler: { placemarks, _ in
            guard let placemark = placemarks?.first,
                  let coordinate = placemark.location?.coordinate else {
                completion(nil)
                return
            }
            let locationForAddress = LocationForAddress(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                addressIn: addressEscaped,
                addressOut: placemark.parsedLocation.addressMin
            )

            // Cache response for performance and offline mode support
            if let data = try? JSONEncoder().encode(locationForAddress) {
                cachedLocationFromAddress?.set(data, forKey: cacheKey)
            }
            completion(locationForAddress)
        })
    }
}
