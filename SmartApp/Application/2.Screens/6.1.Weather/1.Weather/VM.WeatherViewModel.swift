//
//  WeatherViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import SwiftUI
import Common
import Core

//
// MARK: - Model
//

struct WeatherModel: Equatable, Hashable {
    let message: String
    let counter: Int

    init(message: String = "", counter: Int = 0) {
        self.message = message
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
        case getWeatherData(userLat: Double?, userLong: Double?)
    }

    struct Dependencies {
        let model: ___Template___Model
        let didSelected: (ModelDto.GetWeatherResponse) -> Void
        let weatherService: WeatherServiceProtocol
    }
}

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var alertModel: Model.AlertModel?
    @Published var loadingModel: Model.LoadingModel?
    @Published var weatherData: [ModelDto.GetWeatherResponse] = []
    private let weatherService: WeatherServiceProtocol
    public init(dependencies: Dependencies) {
        self.weatherService = dependencies.weatherService
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
        case .getWeatherData(userLat: let userLat, userLong: let userLong):
            Task { @MainActor in
                loadingModel = .loading(message: "Loading".localizedMissing)
                weatherData.removeAll()
                if let userLat = userLat, let userLong = userLong {
                    let userData = try await weatherService.getWeather(
                        .init(
                            latitude: userLat.description,
                            longitude: userLong.description
                        )
                    )
                    weatherData.append(userData)
                }
                for coordinate in coordinates {
                    do {
                        let data = try await weatherService.getWeather(
                            .init(
                                latitude: coordinate.coord.lat.description,
                                longitude: coordinate.coord.long.description
                            )
                        )
                        weatherData.append(data)
                    } catch {
                        ErrorsManager.handleError(message: "\(Self.self).\(action)", error: error)
                        alertModel = .tryAgainLatter
                    }
                }
                loadingModel = .notLoading
            }
        }
    }
}

#Preview {
    WeatherViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
