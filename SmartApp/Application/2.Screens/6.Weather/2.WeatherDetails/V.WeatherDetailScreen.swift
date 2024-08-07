//
//  WeatherDetailScreen.swift
//  SmartApp
//
//  Created by Ricardo Santos on 03/01/24.
//

import SwiftUI
//
import Common
import Core
import DevTools
import DesignSystem

//
// MARK: - Coordinator
//
struct WeatherDetailsViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var coordinator = RouterViewModel()

    // MARK: - Usage Attributes
    @EnvironmentObject var coordinatorTab1: RouterViewModel
    let model: WeatherDetailsModel

    // MARK: - Body & View
    var body: some View {
        buildScreen(.weatherDetailsWith(model: model))
            .sheet(item: $coordinator.sheetLink, content: buildScreen)
            .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .weatherDetailsWith(model: let model):
            let dependencies: WeatherDetailsViewModel.Dependencies = .init(
                model: model, weatherService: configuration.weatherService, onRouteBack: {
                    coordinatorTab1.navigateBack()
                }
            )
            WeatherDetailsView(dependencies: dependencies)
        default:
            EmptyView().onAppear(perform: {
                DevTools.assert(false, message: "Not predicted \(screen)")
            })
        }
    }
}

//
// MARK: - View
//

struct WeatherDetailsView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: WeatherDetailsViewModel
    // MARK: - Usage Attributes
    let onRouteBack: () -> Void
    // MARK: - Constructor
    public init(dependencies: WeatherDetailsViewModel.Dependencies) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onRouteBack = dependencies.onRouteBack
    }

    // MARK: - Body & View
    var body: some View {
        if Common_Utils.onSimulator {
            // swiftlint:disable redundant_discardable_let
            let _ = Self._printChanges()
            // swiftlint:enable redundant_discardable_let
        }
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .weatherDetailsWith(model: .init(weatherResponse: .mockLisbon14March2023!)),
            navigationViewModel: .custom(onBackButtonTap: {
                onRouteBack()
            }, title: "Weather Details".localizedMissing),
            background: .default,
            loadingModel: viewModel.loadingModel,
            alertModel: viewModel.alertModel,
            networkStatus: nil
        ) {
            content
        }.onAppear {
            viewModel.send(action: .didAppear)
        }.onDisappear {
            viewModel.send(action: .didDisappear)
        }
    }

    var content: some View {
        VStack(spacing: 0) {
            infoText(
                text: "Temperature".localizedMissing,
                value: viewModel.model.weatherResponse.currentWeather?.temperature,
                unit: " °C"
            )
            Spacer()
        }
        .padding()
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension WeatherDetailsView {}

//
// MARK: - Private
//
fileprivate extension WeatherDetailsView {
    func infoText(text: String, value: Double?, unit: String) -> some View {
        TitleAndValueView(title: text, value: "\(value ?? 0) \(unit)")
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    WeatherDetailsViewCoordinator(model: .init(weatherResponse: .mockLisbon14March2023!))
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
