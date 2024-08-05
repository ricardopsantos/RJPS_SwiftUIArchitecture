//
//  WeatherScreen.swift
//  SmartApp
//
//  Created by Ricardo Santos on 03/01/24.
//

import SwiftUI
//
import DevTools
import Common
import DesignSystem

//
// MARK: - Coordinator
//

struct WeatherViewCoordinator: View {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @EnvironmentObject var coordinatorTab1: RouterViewModel
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage Attributes

    // MARK: - Body & View
    var body: some View {
        buildScreen(.weather)
            .sheet(item: $coordinator.sheetLink, content: buildScreen)
            .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .weather:
            let dependencies: WeatherViewModel.Dependencies = .init(
                model: .init(), onSelected: { model in
                    coordinatorTab1.navigate(to: .weatherDetailsWith(model: .init(weatherResponse: model)))
                }, weatherService: configuration.weatherService
            )
            WeatherView(dependencies: dependencies)
        case .weatherDetailsWith(model: let model):
            // WeatherDetailsViewCoordinator(model: model)
            let dependencies: WeatherDetailsViewModel.Dependencies = .init(
                model: .init(weatherResponse: model.weatherResponse),
                weatherService: configuration.weatherService,
                onRouteBack: {
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

struct WeatherView: View {
    // MARK: - ViewProtocol

    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: WeatherViewModel
    let onSelected: (ModelDto.GetWeatherResponse) -> Void
    public init(dependencies: WeatherViewModel.Dependencies) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onSelected = dependencies.onSelected
    }

    // MARK: - Usage Attributes
    @StateObject var locationViewModel: Common.CoreLocationManagerViewModel = .shared

    // MARK: - Body & View
    var body: some View {
        if Common_Utils.onSimulator {
            // swiftlint:disable redundant_discardable_let
            let _ = Self._printChanges()
            // swiftlint:enable redundant_discardable_let
        }
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .weather,
            navigationViewModel: .disabled,
            background: .default,
            loadingModel: viewModel.loadingModel,
            alertModel: viewModel.alertModel
        ) {
            content
        }.onAppear {
            viewModel.send(action: .didAppear)
            locationViewModel.start()
        }.onDisappear {
            viewModel.send(action: .didDisappear)
            locationViewModel.stop()
        }
    }

    var content: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: SizeNames.defaultMargin) {
                    ForEach(viewModel.weatherData, id: \.self) { item in
                        ListItemView(
                            title: item.timezone ?? "",
                            subTitle: makeDescription(weatherItem: item),
                            onTapGesture: {
                                onSelected(item)
                            }
                        )
                    }
                }
                .padding(.top, SizeNames.defaultMargin)
                .padding(.horizontal, SizeNames.defaultMargin)
            }
        }
        .frame(maxWidth: .infinity)
        .onChange(of: locationViewModel.coordinates) { some in
            viewModel.send(action: .getWeatherData(
                userLat: some?.latitude,
                userLong: some?.longitude
            ))
        }
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension WeatherView {}

//
// MARK: - Private
//
fileprivate extension WeatherView {
    func makeDescription(weatherItem: ModelDto.GetWeatherResponse) -> String {
        let location = "• Coords: \(weatherItem.latitude!) | \(weatherItem.longitude!)\n"
        let temperature2MMax = weatherItem.daily?.temperature2MMax?.first ?? 0
        let maxTemperature = "• Max Temperature".localizedMissing + ": " + "\(temperature2MMax) °C \n"
        return maxTemperature + location
    }
}

#Preview {
    WeatherViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
