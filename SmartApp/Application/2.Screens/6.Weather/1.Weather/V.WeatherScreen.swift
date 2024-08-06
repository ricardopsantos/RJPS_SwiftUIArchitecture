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

struct WeatherView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: WeatherViewModel
    // MARK: - Usage Attributes
    @StateObject var locationViewModel: Common.CoreLocationManagerViewModel = .shared
    @StateObject var networkMonitorViewModel: Common.NetworkMonitorViewModel = .shared
    private let onSelected: (ModelDto.GetWeatherResponse) -> Void
    // MARK: - Constructor
    public init(dependencies: WeatherViewModel.Dependencies) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onSelected = dependencies.onSelected
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
            appScreen: .weather,
            navigationViewModel: .disabled,
            background: .default,
            loadingModel: viewModel.loadingModel,
            alertModel: viewModel.alertModel,
            networkStatus: networkMonitorViewModel.networkStatus
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
                Header(text: "Current Weather")
                counterView
                listView
            }
        }
        .frame(maxWidth: .infinity)
        .onChange(of: networkMonitorViewModel.networkStatus) { networkStatus in
            switch networkStatus {
            case .unknown, .internetConnectionAvailable, .internetConnectionLost:
                ()
            case .internetConnectionRecovered:
                viewModel.send(action: .getWeatherData(
                    userLat: locationViewModel.coordinates?.latitude,
                    userLong: locationViewModel.coordinates?.longitude
                ))
            }
        }
        .onChange(of: locationViewModel.coordinates) { coordinates in
            viewModel.send(action: .getWeatherData(
                userLat: coordinates?.latitude,
                userLong: coordinates?.longitude
            ))
        }
    }

    var counterView: some View {
        HStack {
            TextButton(onClick: {
                viewModel.send(action: .incrementCounter)
            }, text: "Increment", style: .textOnly, accessibility: .undefined)
                .frame(maxWidth: screenWidth / 4)
            Spacer()
            Text("Counter: \(viewModel.counter.description)")
                .fontSemantic(.callout)
        }
        .padding(.horizontal, SizeNames.defaultMargin)
    }

    var listView: some View {
        VStack(spacing: SizeNames.defaultMargin) {
            ForEach(viewModel.weatherData, id: \.self) { item in
                ListItemView(
                    title: item.timezone ?? "",
                    subTitle: makeDescription(
                        weatherItem: item,
                        latitude: item.latitude,
                        longitude: item.longitude
                    ),
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

//
// MARK: - Auxiliar Views
//
fileprivate extension WeatherView {}

//
// MARK: - Private
//
fileprivate extension WeatherView {
    func makeDescription(
        weatherItem: ModelDto.GetWeatherResponse,
        latitude: Double?,
        longitude: Double?
    ) -> String {
        let temperature2MMax = weatherItem.daily?.temperature2MMax?.first ?? 0
        let maxTemperature = "• Max Temperature".localizedMissing + ": " + "\(temperature2MMax) °C \n"
        if let latitude = latitude, let longitude = longitude {
            let location = "• Coords: \(latitude) | \(longitude)\n"
            return maxTemperature + location
        } else {
            return maxTemperature
        }
    }
}

#Preview {
    WeatherViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
