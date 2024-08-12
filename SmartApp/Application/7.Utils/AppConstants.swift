//
//  AppConstants.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//
import Common

public enum AppConstants {
    static let weatherAppId = "1d8b7e6f3849be9a808176f247698ec3".decrypted
    static let countriesOptions = ["Portugal", "Spain", "Other"]

    static var worldCities: [(city: String, coord: (lat: String, long: String))] { [
        (city: "Lisbon", coord: (lat: "38.736946", long: "-9.142685")),
        (city: "Paris", coord: (lat: "48.85661400", long: "2.35222190")),
        (city: "New York", coord: (lat: "40.730610", long: "-73.935242")),
        (city: "Tokyo", coord: (lat: "35.689487", long: "139.691706")),
        (city: "London", coord: (lat: "51.507351", long: "-0.127758")),
        (city: "Sydney", coord: (lat: "-33.868820", long: "151.209296")),
        (city: "Dubai", coord: (lat: "25.204849", long: "55.270783")),
        (city: "Rio de Janeiro", coord: (lat: "-22.906847", long: "-43.172896")),
        (city: "Moscow", coord: (lat: "55.755826", long: "37.617300")),
        (city: "Beijing", coord: (lat: "39.904202", long: "116.407394")),
        (city: "Mumbai", coord: (lat: "19.076090", long: "72.877426")),
        (city: "Cairo", coord: (lat: "30.044420", long: "31.235712")),
        (city: "Bangkok", coord: (lat: "13.756331", long: "100.501765")),
        (city: "Mexico City", coord: (lat: "19.432608", long: "-99.133209")),
        (city: "Johannesburg", coord: (lat: "-26.204103", long: "28.047305")),
        (city: "Berlin", coord: (lat: "52.520007", long: "13.404954")),
        (city: "Buenos Aires", coord: (lat: "-34.603684", long: "-58.381559")),
        (city: "Lagos", coord: (lat: "6.524379", long: "3.379206")),
        (city: "Los Angeles", coord: (lat: "34.052235", long: "-118.243683")),
        (city: "Toronto", coord: (lat: "43.653225", long: "-79.383186"))
    ]
    }
}
