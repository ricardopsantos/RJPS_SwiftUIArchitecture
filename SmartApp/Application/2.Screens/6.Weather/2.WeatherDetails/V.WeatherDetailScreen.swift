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
    public init(dependencies: WeatherDetailsViewModel.Dependencies) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onRouteBack = dependencies.onRouteBack
    }

    // MARK: - Usage Attributes
    @Environment(\.dismiss) var dismiss
    // @State var someVar = 0
    // @StateObject var networkMonitorViewModel: Common.NetworkMonitorViewModel = .shared

    // MARK: - Auxiliar Attributes
    private let onRouteBack: () -> Void

    // MARK: - Body & View
    var body: some View {
        if Common_Utils.onSimulator {
            // swiftlint:disable redundant_discardable_let
            let _ = Self._printChanges()
            // swiftlint:enable redundant_discardable_let
        }
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .weatherDetailsWith(model: .init(latitude: 0, longitude: 0)),
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
            locationView(value: viewModel.model?.location)
            temperatureMaxView(value: viewModel.model?.temperatureMax)
            temperatureMinView(value: viewModel.model?.temperatureMin)
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
    @ViewBuilder
    func locationView(value: String?) -> some View {
        if let value = value {
            TitleAndValueView(
                title: "Location".localizedMissing,
                value: value
            )
        }
        EmptyView()
    }

    @ViewBuilder
    func temperatureMaxView(value: Double?) -> some View {
        if let value = value {
            TitleAndValueView(
                title: "Temperature Max".localizedMissing,
                value: "\(value.localeString) °C"
            )
        }
        EmptyView()
    }

    @ViewBuilder
    func temperatureMinView(value: Double?) -> some View {
        if let value = value {
            TitleAndValueView(
                title: "Temperature Min".localizedMissing,
                value: "\(value.localeString) °C"
            )
        }
        EmptyView()
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    WeatherDetailsViewCoordinator(model: .init())
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
