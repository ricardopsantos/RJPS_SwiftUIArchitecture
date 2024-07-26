//
//  WeatherRequest.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import Common

public extension ModelDto {
    struct GetWeatherRequest: ModelDtoProtocol {
        public var latitude, longitude: String
        public init(latitude: String, longitude: String) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }
}
