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

//
// MARK: - Coordinator
//
struct WeatherDetailsViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var router = RouterViewModel()
    // MARK: - Usage Attributes
    let model: WeatherDetailsModel

    // MARK: - Body & View
    var body: some View {
        NavigationStack(path: $router.navPath) {
            buildScreen(.weatherDetailsWith(model: model))
                .navigationDestination(for: AppScreen.self, destination: buildScreen)
                .sheet(item: $router.sheetLink, content: buildScreen)
                .fullScreenCover(item: $router.coverLink, content: buildScreen)
        }
        .environmentObject(router)
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .weatherDetailsWith(model: let model):
            let dependencies: WeatherDetailsViewModel.Dependencies = .init(
                model: model, weatherService: configuration.weatherService
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
    @EnvironmentObject var router: RouterViewModel
    @StateObject var viewModel: WeatherDetailsViewModel
    public init(dependencies: WeatherDetailsViewModel.Dependencies) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
    }

    // MARK: - Body & View
    var body: some View {
        if Common_Utils.true {
            // swiftlint:disable no_letUnderscore redundant_discardable_let
            let _ = Self._printChanges()
            // swiftlint:enable no_letUnderscore redundant_discardable_let
        }
        BaseView.with(
            sender: "\(Self.self)",
            appScreen: .weatherDetailsWith(model: .init(weatherResponse: .mockLisbon14March2023!)),
            navigationViewEmbed: false,
            scrollViewEmbed: false,
            ignoresSafeArea: false,
            background: .gradient,
            alertModel: viewModel.alertModel
        ) {
            content
        }.onAppear {
            viewModel.send(action: .didAppear)
        }.onDisappear {
            viewModel.send(action: .didDisappear)
        }
    }

    var content: some View {
        VStack {
            Header(
                text: "Weather".localizedMissing,
                hasCloseButton: true,
                onBackOrCloseClick: {
                    //   dismiss()
                }
            )
            Spacer()
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

#Preview {
    WeatherDetailsViewCoordinator(model: .init(weatherResponse: .mockLisbon14March2023!))
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}