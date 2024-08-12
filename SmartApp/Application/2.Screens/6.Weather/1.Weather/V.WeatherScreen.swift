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
                citiesCount: 1, model: .init(), onSelected: { model in
                    let detailsModel: WeatherDetailsModel = .init(
                        latitude: model.latitude,
                        longitude: model.longitude
                    )
                    coordinatorTab1.navigate(to: .weatherDetailsWith(model: detailsModel))
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
    public init(dependencies: WeatherViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onSelected = dependencies.onSelected
    }

    // MARK: - Usage Attributes
    @Environment(\.dismiss) var dismiss
    @StateObject var locationViewModel: Common.CoreLocationManagerViewModel = .shared
    @StateObject var networkMonitorViewModel: Common.NetworkMonitorViewModel = .shared

    // MARK: - Auxiliar Attributes
    private let onSelected: (WeatherModel) -> Void

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
            background: .defaultBackground,
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
        VStack(spacing: 0, content: {
            ScrollView(showsIndicators: false) {
                Header(text: "Current Weather".localizedMissing)
                counterView
                listView
            }
        })

        .frame(maxWidth: .infinity)
        .onChange(of: networkMonitorViewModel.networkStatus) { networkStatus in
            switch networkStatus {
            case .internetConnectionRecovered:
                getWeatherData()
            default: ()
            }
        }
        .onChange(of: locationViewModel.coordinates) { _ in
            getWeatherData()
        }
    }

    var counterView: some View {
        HStack(spacing: 0) {
            TextButton(
                onClick: {
                    viewModel.send(action: .incrementCitiesCounter)
                    getWeatherData()
                },
                text: "Add more cities".localizedMissing,
                alignment: .leading,
                style: .textOnly,
                accessibility: .undefined
            )
            .offset(.init(width: -SizeNames.defaultMarginSmall, height: 0))
            Spacer()
            Text("Cities: \(viewModel.citiesCount.description)".localizedMissing)
                .fontSemantic(.callout)
        }
        .padding(.horizontal, SizeNames.defaultMargin)
    }

    var listView: some View {
        VStack(spacing: SizeNames.defaultMarginSmall) {
            ForEach(viewModel.model, id: \.self) { item in
                ListItemView(
                    title: item.title,
                    subTitle: item.subTitle,
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
    func getWeatherData() {
        viewModel.send(action: .getWeatherData(
            userLatitude: locationViewModel.coordinates?.latitude,
            userLongitude: locationViewModel.coordinates?.longitude
        ))
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
