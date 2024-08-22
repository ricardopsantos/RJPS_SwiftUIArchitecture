//
//  WeatherDetailsViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 20/05/2024.
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
public struct WeatherDetailsModel: Equatable, Hashable, Sendable {
    let temperatureMax: Double?
    let temperatureMin: Double?
    let latitude: Double
    let longitude: Double
    let location: String
    public init(
        latitude: Double = 38.71,

        longitude: Double = 9.14,
        temperatureMax: Double? = 0,
        temperatureMin: Double? = 0,
        location: String = ""
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.temperatureMax = temperatureMax
        self.temperatureMin = temperatureMin
        self.location = location
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension WeatherDetailsViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case load
    }

    struct Dependencies {
        let model: WeatherDetailsModel
        let weatherService: WeatherServiceProtocol
        let onRouteBack: () -> Void
    }
}

//
// MARK: - View
//
class WeatherDetailsViewModel: BaseViewModel {
    // MARK: - View Usage Attributes
    @Published var model: WeatherDetailsModel?
    // MARK: - Auxiliar Attributes
    private let weatherService: WeatherServiceProtocol?
    public init(dependencies: Dependencies) {
        self.weatherService = dependencies.weatherService
        self.model = dependencies.model
        super.init()
    }

    func send(action: Actions) {
        switch action {
        case .didAppear:
            send(action: .load)
        case .didDisappear: ()
        case .load:
            Task { [weak self] in
                guard let self = self else { return }
                self.loadingModel = .loading(message: "Loading".localizedMissing)
                if let latitude = model?.latitude, let longitude = model?.longitude {
                    let modelDto = try await self.weatherService?.getWeather(
                        .init(
                            latitude: latitude.description,
                            longitude: longitude.description
                        ), cachePolicy: .cacheElseLoad
                    )
                    let coordinates = try await Common.CoreLocationManager.getAddressFromAsync(
                        latitude: latitude,
                        longitude: longitude
                    )

                    let temperatureMax = modelDto?.daily?.temperature2MMax?.first
                    let temperatureMin = modelDto?.daily?.temperature2MMin?.first
                    model = .init(
                        latitude: latitude,
                        longitude: longitude,
                        temperatureMax: temperatureMax,
                        temperatureMin: temperatureMin,
                        location: coordinates.addressMin
                    )
                    self.loadingModel = .notLoading
                }
            }
        }
    }
}

//
// MARK: - Preview
//
#if canImport(SwiftUI) && DEBUG
#Preview {
    WeatherDetailsViewCoordinator(model: .init(latitude: 38.71, longitude: -9.14))
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
