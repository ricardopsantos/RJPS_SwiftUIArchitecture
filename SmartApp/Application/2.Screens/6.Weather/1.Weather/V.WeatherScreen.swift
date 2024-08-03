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
struct WeatherViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var router = RouterViewModel()
    // MARK: - Usage Attributes

    // MARK: - Body & View
    var body: some View {
        NavigationStack(path: $router.navPath) {
            buildScreen(.weather)
                .navigationDestination(for: AppScreen.self, destination: buildScreen)
                .sheet(item: $router.sheetLink, content: buildScreen)
                .fullScreenCover(item: $router.coverLink, content: buildScreen)
        }
        .environmentObject(router)
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .weather:
            let dependencies: WeatherViewModel.Dependencies = .init(
                model: .init(), didSelected: { some in
                    DevTools.Log.debug("\(some)", .generic)
                }, weatherService: configuration.weatherService
            )
            WeatherView(dependencies: dependencies)
        case .weatherDetailsWith(model: let model):
            WeatherDetailsViewCoordinator(model: model)
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
    @EnvironmentObject var router: RouterViewModel
    @StateObject var viewModel: WeatherViewModel
    let didSelected: (ModelDto.GetWeatherResponse) -> Void
    public init(dependencies: WeatherViewModel.Dependencies) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.didSelected = dependencies.didSelected
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
                    ForEach(viewModel.weatherData, id: \.self) { data in
                        ListItemView(
                            title: data.timezone ?? "",
                            subTitle: makeDescription(weatherItem: data)
                        )
                        .onTapGesture {
                            guard let index = viewModel.weatherData.firstIndex(of: data),
                                  let model = viewModel.weatherData.safeItem(at: index) else {
                                return
                            }
                            router.coverLink = .weatherDetailsWith(model: .init(weatherResponse: model))
                            // didSelected(model)
                        }
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
