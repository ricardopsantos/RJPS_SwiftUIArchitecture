//
//  WeatherViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import SwiftUI
//
import Domain
import Common
import Core

//
// MARK: - Model
//

struct WeatherModel: Equatable, Hashable, Sendable {
    let title: String
    let subTitle: String
    let latitude: Double
    let longitude: Double
    init(
        title: String = "",
        subTitle: String = "",
        latitude: Double = 0,
        longitude: Double = 0
    ) {
        self.title = title
        self.subTitle = subTitle
        self.latitude = latitude
        self.longitude = longitude
    }

    init(
        title: String,
        getWeatherResponse modelDto: ModelDto.GetWeatherResponse
    ) {
        let temperature2MMax = modelDto.daily?.temperature2MMax?.first ?? 0
        let temperature2MMin = modelDto.daily?.temperature2MMin?.first ?? 0
        let temperatureAvg = (temperature2MMax + temperature2MMin) / 2
        let maxTemperature = "• Avg Temperature".localizedMissing + ": " + "\(temperatureAvg.localeString) °C \n"
        if let latitude = modelDto.latitude, let longitude = modelDto.longitude {
            let location = "• Coords: \(latitude) | \(longitude)\n"
            self.subTitle = maxTemperature + location
        } else {
            self.subTitle = maxTemperature
        }
        self.title = title
        self.latitude = modelDto.latitude ?? 0
        self.longitude = modelDto.longitude ?? 0
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension WeatherViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case incrementCounter
        case getWeatherData(userLatitude: Double?, userLongitude: Double?)
    }

    struct Dependencies {
        let counter: Int
        let model: WeatherModel
        let onSelected: (WeatherModel) -> Void
        let weatherService: WeatherServiceProtocol
    }
}

class WeatherViewModel: BaseViewModel {
    // MARK: - View Usage Attributes
    @Published var model: [WeatherModel] = []
    @Published var counter: Int = 0

    // MARK: - Auxiliar Attributes
    private let weatherService: WeatherServiceProtocol
    public init(dependencies: Dependencies) {
        self.weatherService = dependencies.weatherService
        self.counter = dependencies.counter
        super.init()
        send(action: .getWeatherData(userLatitude: nil, userLongitude: nil))
    }

    private let otherLocations: [(city: String, coord: (lat: String, long: String))] = [
        (city: "Lisbon", coord: (lat: "38.736946", long: "-9.142685")),
        (city: "Paris", coord: (lat: "48.85661400", long: "2.35222190")),
        (city: "New York", coord: (lat: "40.730610", long: "-73.935242"))
    ]

    func send(action: Actions) {
        switch action {
        case .didAppear:
            ()
        case .didDisappear:
            ()
        case .incrementCounter:
            counter += 1
        case .getWeatherData(userLatitude: let userLatitude, userLongitude: let userLongitude):
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.loadingModel = .loading(message: "Loading".localizedMissing)
                model.removeAll()
                if let userLatitude = userLatitude, let userLongitude = userLongitude {
                    let modelDto = try await self.weatherService.getWeather(
                        .init(
                            latitude: userLatitude.description,
                            longitude: userLongitude.description
                        ), cachePolicy: .cacheElseLoad
                    )
                    let coordinates = try await Common.CoreLocationManager.getAddressFromAsync(
                        latitude: userLatitude,
                        longitude: userLongitude
                    )
                    model.append(.init(
                        title: "User @ \(coordinates.0)",
                        getWeatherResponse: modelDto
                    ))
                }
                for location in self.otherLocations {
                    do {
                        let latitude = location.coord.lat
                        let longitude = location.coord.long
                        let modelDto = try await self.weatherService.getWeather(
                            .init(
                                latitude: latitude.description,
                                longitude: longitude.description
                            ), cachePolicy: .cacheElseLoad
                        )
                        model.append(.init(
                            title: location.city,
                            getWeatherResponse: modelDto
                        ))

                    } catch {
                        handle(error: error, sender: "\(Self.self).\(action)")
                    }
                }
                loadingModel = .notLoading
            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    WeatherViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
