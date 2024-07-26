//
//  WeatherDetailsViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 20/05/2024.
//

import Foundation
import SwiftUI
//
import Common
import Core

//
// MARK: - Model
//

struct WeatherDetailsModel: Equatable, Hashable {
    let weatherResponse: ModelDto.GetWeatherResponse

    init(weatherResponse: ModelDto.GetWeatherResponse) {
        self.weatherResponse = weatherResponse
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension WeatherDetailsViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case doSomething
    }

    struct Dependencies {
        let model: WeatherDetailsModel
        let weatherService: WeatherServiceProtocol
    }
}

//
// MARK: - View
//
@MainActor
class WeatherDetailsViewModel: ObservableObject {
    @Published var alertModel: Model.AlertModel?
    @Published var model: WeatherDetailsModel
    private let weatherService: WeatherServiceProtocol?
    public init(dependencies: Dependencies) {
        self.weatherService = dependencies.weatherService
        self.model = dependencies.model
    }

    func send(action: Actions) {
        switch action {
        case .didAppear: ()
        case .didDisappear: ()
        case .doSomething: () // Do something
        }
    }
}

#Preview {
    WeatherDetailsViewCoordinator(model: .init(weatherResponse: .mockLisbon14March2023!))
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}