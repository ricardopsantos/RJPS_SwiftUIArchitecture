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
    let latitude: Double
    let longitude: Double

    public init(latitude: Double = 38.71, longitude: Double = 9.14) {
        self.latitude = latitude
        self.longitude = longitude
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
        let onRouteBack: () -> Void
    }
}

//
// MARK: - View
//
class WeatherDetailsViewModel: BaseViewModel {
    // MARK: - View Usage Attributes
    let model: WeatherDetailsModel
    // MARK: - Auxiliar Attributes
    private let weatherService: WeatherServiceProtocol?
    public init(dependencies: Dependencies) {
        self.weatherService = dependencies.weatherService
        self.model = dependencies.model
        super.init()
    }

    func send(action: Actions) {
        switch action {
        case .didAppear: ()
        case .didDisappear: ()
        case .doSomething: () // Do something
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
