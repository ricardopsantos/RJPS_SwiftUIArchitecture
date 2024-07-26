//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreLocation

public typealias CLPlacemarkAsJSON = (jsonString: String, jsonAsData: Data, jsonAsDic: [String: String])

public extension CLPlacemark {
    var asJSON: CLPlacemarkAsJSON? {
        var jsonAsDic: [String: String] = [:]
        if let some = name { jsonAsDic["name"] = some }
        if let some = thoroughfare { jsonAsDic["thoroughfare"] = some }
        if let some = subThoroughfare { jsonAsDic["subThoroughfare"] = some }
        if let some = locality { jsonAsDic["locality"] = some }
        if let some = subLocality { jsonAsDic["subLocality"] = some }
        if let some = administrativeArea { jsonAsDic["administrativeArea"] = some }
        if let some = subAdministrativeArea { jsonAsDic["subAdministrativeArea"] = some }
        if let some = postalCode { jsonAsDic["postalCode"] = some }
        if let some = isoCountryCode { jsonAsDic["isoCountryCode"] = some }
        if let some = country { jsonAsDic["country"] = some }
        if let some = inlandWater { jsonAsDic["inlandWater"] = some }
        if let some = ocean { jsonAsDic["ocean"] = some }
        if let some = ocean { jsonAsDic["ocean"] = some }

        // Convert the JSON dictionary to Data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonAsDic, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return (jsonString, jsonData, jsonAsDic)
            }
        } catch {
            return nil
        }
        return nil
    }

    /// Esslinger Str. 7 • 70771 Leinfelden-Echterdingen
    var parsedLocation: (addressMin: String, addressFull: String) {
        var addressMin: String = ""
        var addressFull: String = ""
        if let value = subLocality {
            addressFull += value + ", "
        }
        if let street = thoroughfare, let streetNumber = subThoroughfare {
            addressFull += street + " " + streetNumber + ", "
            addressMin += street + " " + streetNumber + ", "
        } else if let street = thoroughfare {
            addressFull += street + ", "
            addressMin += street + ", "
        }
        if let zipCode = postalCode {
            addressFull += zipCode + " "
            addressMin += zipCode + " "
        }
        if let city = locality {
            addressFull += city + ", "
            addressMin += city
        }
        if let country {
            addressFull += country
        }
        if addressMin.hasSuffix(", ") {
            addressMin = "\(addressMin.dropLast())"
            addressMin = "\(addressMin.dropLast())"
        }
        if addressFull.hasSuffix(", ") {
            addressFull = "\(addressFull.dropLast())"
            addressFull = "\(addressFull.dropLast())"
        }
        return (addressMin, addressFull)
    }
}
