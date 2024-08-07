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

struct WeatherModel: Equatable, Hashable {
    let counter: Int

    init(counter: Int = 0) {
        self.counter = counter
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
        case getWeatherData(userLat: Double?, userLong: Double?)
    }

    struct Dependencies {
        let model: ___Template___Model
        let onSelected: (ModelDto.GetWeatherResponse) -> Void
        let weatherService: WeatherServiceProtocol
    }
}

class WeatherViewModel: BaseViewModel {
    // MARK: - View Usage Attributes
    @Published var weatherData: [ModelDto.GetWeatherResponse] = []

    // MARK: - Auxiliar Attributes
    @Published var counter: Int = 0
    private let weatherService: WeatherServiceProtocol

    public init(dependencies: Dependencies) {
        self.weatherService = dependencies.weatherService
        self.counter = dependencies.model.counter
        super.init()
        send(action: .getWeatherData(userLat: nil, userLong: nil))
    }

    private let coordinates: [(city: String, coord: (lat: String, long: String))] = [
        ("Lisbon", ("38.736946", "-9.142685"))
    ]

    func send(action: Actions) {
        switch action {
        case .didAppear:
            ()
        case .didDisappear:
            ()
        case .incrementCounter:
            counter += 1
        case .getWeatherData(userLat: let userLat, userLong: let userLong):
            Task { @MainActor in
                loadingModel = .loading(message: "Loading".localizedMissing)
                weatherData.removeAll()
                if let userLat = userLat, let userLong = userLong {
                    let userData = try await weatherService.getWeather(
                        .init(
                            latitude: userLat.description,
                            longitude: userLong.description
                        ), cachePolicy: .cacheElseLoad
                    )
                    weatherData.append(userData)
                }
                for coordinate in coordinates {
                    do {
                        let data = try await weatherService.getWeather(
                            .init(
                                latitude: coordinate.coord.lat.description,
                                longitude: coordinate.coord.long.description
                            ), cachePolicy: .cacheElseLoad
                        )
                        weatherData.append(data)
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
