//
//  Weather.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import Common

public extension ModelDto {
    struct GetWeatherResponse: ModelDtoProtocol {
        public var latitude, longitude, generationtimeMS: Double?
        public var utcOffsetSeconds: Int?
        public var timezone, timezoneAbbreviation: String?
        public var elevation: Int?
        public var currentWeather: CurrentWeather?
        public var hourlyUnits: HourlyUnits?
        public var hourly: Hourly?
        public let dailyUnits: DailyUnits?
        public let daily: Daily?

        enum CodingKeys: String, CodingKey {
            case latitude
            case longitude
            case generationtimeMS = "generationtime_ms"
            case utcOffsetSeconds = "utc_offset_seconds"
            case timezone
            case timezoneAbbreviation = "timezone_abbreviation"
            case elevation
            case currentWeather = "current_weather"
            case hourlyUnits = "hourly_units"
            case hourly
            case dailyUnits = "daily_units"
            case daily
        }
    }

    struct Daily: ModelDtoProtocol {
        public let time: [String]?
        public let temperature2MMax, temperature2MMin: [Double]?

        enum CodingKeys: String, CodingKey {
            case time
            case temperature2MMax = "temperature_2m_max"
            case temperature2MMin = "temperature_2m_min"
        }
    }

    struct DailyUnits: ModelDtoProtocol {
        public let time, temperature2MMax, temperature2MMin: String?

        enum CodingKeys: String, CodingKey {
            case time
            case temperature2MMax = "temperature_2m_max"
            case temperature2MMin = "temperature_2m_min"
        }
    }

    struct CurrentWeather: ModelDtoProtocol {
        public let temperature, windspeed: Double?
        public let winddirection, weathercode: Int?
        public let time: String?
    }

    struct Hourly: ModelDtoProtocol {
        public let time: [String]?
        public let temperature2M: [Double]?
        public let relativehumidity2M: [Int]?
        public let windspeed10M: [Double]?

        enum CodingKeys: String, CodingKey {
            case time
            case temperature2M = "temperature_2m"
            case relativehumidity2M = "relativehumidity_2m"
            case windspeed10M = "windspeed_10m"
        }
    }

    struct HourlyUnits: ModelDtoProtocol {
        public let time, temperature2M, relativehumidity2M, windspeed10M: String?

        enum CodingKeys: String, CodingKey {
            case time
            case temperature2M = "temperature_2m"
            case relativehumidity2M = "relativehumidity_2m"
            case windspeed10M = "windspeed_10m"
        }
    }
}

public extension ModelDto.GetWeatherResponse {
    static var mockBigLoad: Self? {
        .init(
            latitude: 38.71,
            longitude: -9.14,
            dailyUnits: .init(
                time: "iso8601",
                temperature2MMax: "32",
                temperature2MMin: "27"),
            daily: .init(
                time: ["2023-03-14T00:00"],
                temperature2MMax: [32],
                temperature2MMin: [27]))
    }

    /// Lisbon14March202
    static var mockRegularLoad: Self? {
        // swiftlint:disable line_length no_hardCodedTimeZones
        let jsonString = """
        {"latitude":38.71,"longitude":-9.14,"generationtime_ms":0.5639791488647461,"utc_offset_seconds":0,"timezone":"GMT","timezone_abbreviation":"GMT","elevation":16.0,"current_weather":{"temperature":14.1,"windspeed":2.2,"winddirection":279.0,"weathercode":3,"time":"2023-03-14T10:00"},"hourly_units":{"time":"iso8601","temperature_2m":"°C","relativehumidity_2m":"%","windspeed_10m":"km/h"},"hourly":{"time":["2023-03-14T00:00","2023-03-14T01:00","2023-03-14T02:00","2023-03-14T03:00","2023-03-14T04:00","2023-03-14T05:00","2023-03-14T06:00","2023-03-14T07:00","2023-03-14T08:00","2023-03-14T09:00","2023-03-14T10:00","2023-03-14T11:00","2023-03-14T12:00","2023-03-14T13:00","2023-03-14T14:00","2023-03-14T15:00","2023-03-14T16:00","2023-03-14T17:00","2023-03-14T18:00","2023-03-14T19:00","2023-03-14T20:00","2023-03-14T21:00","2023-03-14T22:00","2023-03-14T23:00","2023-03-15T00:00","2023-03-15T01:00","2023-03-15T02:00","2023-03-15T03:00","2023-03-15T04:00","2023-03-15T05:00","2023-03-15T06:00","2023-03-15T07:00","2023-03-15T08:00","2023-03-15T09:00","2023-03-15T10:00","2023-03-15T11:00","2023-03-15T12:00","2023-03-15T13:00","2023-03-15T14:00","2023-03-15T15:00","2023-03-15T16:00","2023-03-15T17:00","2023-03-15T18:00","2023-03-15T19:00","2023-03-15T20:00","2023-03-15T21:00","2023-03-15T22:00","2023-03-15T23:00","2023-03-16T00:00","2023-03-16T01:00","2023-03-16T02:00","2023-03-16T03:00","2023-03-16T04:00","2023-03-16T05:00","2023-03-16T06:00","2023-03-16T07:00","2023-03-16T08:00","2023-03-16T09:00","2023-03-16T10:00","2023-03-16T11:00","2023-03-16T12:00","2023-03-16T13:00","2023-03-16T14:00","2023-03-16T15:00","2023-03-16T16:00","2023-03-16T17:00","2023-03-16T18:00","2023-03-16T19:00","2023-03-16T20:00","2023-03-16T21:00","2023-03-16T22:00","2023-03-16T23:00","2023-03-17T00:00","2023-03-17T01:00","2023-03-17T02:00","2023-03-17T03:00","2023-03-17T04:00","2023-03-17T05:00","2023-03-17T06:00","2023-03-17T07:00","2023-03-17T08:00","2023-03-17T09:00","2023-03-17T10:00","2023-03-17T11:00","2023-03-17T12:00","2023-03-17T13:00","2023-03-17T14:00","2023-03-17T15:00","2023-03-17T16:00","2023-03-17T17:00","2023-03-17T18:00","2023-03-17T19:00","2023-03-17T20:00","2023-03-17T21:00","2023-03-17T22:00","2023-03-17T23:00","2023-03-18T00:00","2023-03-18T01:00","2023-03-18T02:00","2023-03-18T03:00","2023-03-18T04:00","2023-03-18T05:00","2023-03-18T06:00","2023-03-18T07:00","2023-03-18T08:00","2023-03-18T09:00","2023-03-18T10:00","2023-03-18T11:00","2023-03-18T12:00","2023-03-18T13:00","2023-03-18T14:00","2023-03-18T15:00","2023-03-18T16:00","2023-03-18T17:00","2023-03-18T18:00","2023-03-18T19:00","2023-03-18T20:00","2023-03-18T21:00","2023-03-18T22:00","2023-03-18T23:00","2023-03-19T00:00","2023-03-19T01:00","2023-03-19T02:00","2023-03-19T03:00","2023-03-19T04:00","2023-03-19T05:00","2023-03-19T06:00","2023-03-19T07:00","2023-03-19T08:00","2023-03-19T09:00","2023-03-19T10:00","2023-03-19T11:00","2023-03-19T12:00","2023-03-19T13:00","2023-03-19T14:00","2023-03-19T15:00","2023-03-19T16:00","2023-03-19T17:00","2023-03-19T18:00","2023-03-19T19:00","2023-03-19T20:00","2023-03-19T21:00","2023-03-19T22:00","2023-03-19T23:00","2023-03-20T00:00","2023-03-20T01:00","2023-03-20T02:00","2023-03-20T03:00","2023-03-20T04:00","2023-03-20T05:00","2023-03-20T06:00","2023-03-20T07:00","2023-03-20T08:00","2023-03-20T09:00","2023-03-20T10:00","2023-03-20T11:00","2023-03-20T12:00","2023-03-20T13:00","2023-03-20T14:00","2023-03-20T15:00","2023-03-20T16:00","2023-03-20T17:00","2023-03-20T18:00","2023-03-20T19:00","2023-03-20T20:00","2023-03-20T21:00","2023-03-20T22:00","2023-03-20T23:00"],"temperature_2m":[12.9,12.5,11.9,12.0,12.0,11.7,11.1,10.5,10.9,12.2,14.1,15.2,16.1,17.0,17.5,18.0,18.3,18.0,17.4,16.1,15.0,14.3,13.6,13.1,12.6,12.2,11.8,11.4,10.9,10.5,10.3,10.2,10.7,11.9,13.4,15.3,16.9,17.9,18.6,19.4,19.8,19.6,18.7,16.9,15.8,14.9,13.9,13.1,12.5,11.8,11.4,11.1,11.0,10.8,10.7,10.4,10.5,11.9,13.9,16.5,17.2,18.7,18.9,18.5,17.3,16.6,15.1,13.8,13.4,12.9,12.6,13.2,14.2,13.9,13.8,13.9,13.7,13.4,13.5,13.2,13.4,14.3,15.1,15.1,15.3,15.2,14.9,14.9,14.8,14.5,14.0,13.6,13.3,13.0,12.8,12.5,12.3,12.0,11.8,11.7,11.5,11.1,10.9,12.8,13.2,13.9,14.6,15.5,16.5,17.1,17.6,18.0,17.8,17.4,16.6,15.8,14.8,13.7,13.3,13.1,12.9,12.8,12.8,12.7,12.4,12.0,11.7,11.7,11.8,12.5,13.6,15.1,16.9,17.9,18.6,19.0,18.6,17.7,16.5,15.6,14.8,13.8,13.2,12.8,12.3,11.9,11.5,11.2,11.1,11.0,11.4,12.2,13.4,14.8,15.7,16.5,17.1,17.2,17.1,16.7,16.4,16.0,15.4,15.0,14.6,14.1,13.8,13.5],"relativehumidity_2m":[79,84,90,90,89,89,93,97,98,96,84,72,64,60,57,56,56,58,60,62,67,70,72,77,83,87,91,93,94,95,93,93,90,85,79,74,70,67,65,61,58,59,46,51,55,55,54,55,65,65,67,63,64,70,75,78,78,79,69,61,63,56,54,61,70,71,93,87,91,93,93,93,88,89,90,88,88,89,87,88,88,84,80,79,81,82,83,80,80,81,84,84,86,90,91,93,92,93,93,93,92,94,95,88,87,84,79,74,67,63,61,59,60,62,67,72,78,84,86,87,87,87,87,88,90,92,94,94,93,90,85,77,69,65,62,60,61,64,69,75,81,89,92,94,96,97,98,99,99,99,98,96,93,88,83,76,70,69,70,73,78,84,90,90,88,86,87,89],"windspeed_10m":[6.2,6.7,6.6,4.7,3.3,2.6,2.4,3.6,4.1,2.6,2.2,4.0,4.0,4.6,4.7,3.5,2.9,7.2,9.3,21.3,17.7,13.7,12.4,11.1,10.0,9.8,9.0,8.1,7.9,8.2,8.7,9.5,10.5,10.8,8.9,7.5,7.2,9.2,9.4,7.0,5.4,10.1,12.1,7.3,2.3,4.2,4.6,3.1,3.2,3.1,4.1,4.3,1.3,1.6,1.1,3.4,2.4,1.6,3.8,2.9,8.2,11.7,19.3,21.2,20.9,22.4,28.4,10.3,10.5,10.3,13.0,13.9,28.2,22.9,23.5,23.8,24.8,25.1,20.4,20.6,17.7,19.5,22.1,26.8,29.0,31.4,30.3,27.5,28.5,27.9,25.1,21.9,18.0,16.3,13.2,12.4,11.5,9.4,9.0,10.0,7.2,7.4,7.1,2.4,2.3,2.3,3.4,5.5,8.4,9.3,9.7,10.5,11.8,13.4,14.0,12.2,9.0,5.6,4.4,3.6,2.5,1.9,1.8,2.2,1.5,0.4,1.5,2.2,2.5,2.9,2.5,1.8,0.5,3.1,6.6,10.2,10.6,10.8,10.6,9.1,7.1,4.7,3.6,3.3,3.9,3.7,3.2,2.7,3.1,4.1,4.9,5.5,6.2,8.1,11.0,14.7,18.8,19.7,19.9,19.1,17.6,15.8,12.7,10.7,8.9,6.8,6.1,5.6]}}
        """

        let jsonData = jsonString.data(using: .utf8)!
        return try? JSONDecoder().decode(Self.self, from: jsonData)
        // swiftlint:enable line_length no_hardCodedTimeZones
    }
}
