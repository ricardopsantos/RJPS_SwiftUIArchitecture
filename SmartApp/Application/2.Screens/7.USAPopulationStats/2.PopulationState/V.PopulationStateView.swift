//
//  PopulationStateView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 02/08/2024.
//

import SwiftUI
//
import DevTools
import Common
import DesignSystem

//
// MARK: - Coordinator
//

struct PopulationStateViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var coordinator = RouterViewModel()

    // MARK: - Usage Attributes
    @EnvironmentObject var coordinatorTab2: RouterViewModel
    let year: String
    let model: [PopulationStateModel]

    // MARK: - Body & View
    var body: some View {
        buildScreen(.populationStates(year: year, model: model))
            .navigationDestination(for: AppScreen.self, destination: buildScreen)
            .sheet(item: $coordinator.sheetLink, content: buildScreen)
            .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .populationStates(year: let year, model: let model):
            let dependencies: PopulationStateViewModel.Dependencies = .init(
                model: model, year: year,
                onRouteBack: {
                    coordinatorTab2.navigateBack()
                }, dataUSAService: configuration.dataUSAService
            )
            PopulationStateView(dependencies: dependencies)

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

struct PopulationStateView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: PopulationStateViewModel
    public init(dependencies: PopulationStateViewModel.Dependencies) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onRouteBack = dependencies.onRouteBack
    }

    // MARK: - Usage Attributes
    @Environment(\.dismiss) var dismiss
    @StateObject var networkMonitorViewModel: Common.NetworkMonitorViewModel = .shared

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
            appScreen: .populationStates(year: "", model: []),
            navigationViewModel: .custom(onBackButtonTap: {
                onRouteBack()
            }, title: viewModel.title),
            background: .linear,
            loadingModel: viewModel.loadingModel,
            alertModel: viewModel.alertModel,
            networkStatus: networkMonitorViewModel.networkStatus
        ) {
            content
        }
        .onAppear {
            viewModel.send(action: .didAppear)
        }.onDisappear {
            viewModel.send(action: .didDisappear)
        }
    }

    var content: some View {
        ScrollView {
            listView
        }
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension PopulationStateView {
    var listView: some View {
        LazyVStack(spacing: SizeNames.defaultMarginSmall) {
            ForEach(Array(viewModel.model.enumerated()), id: \.element) { _, item in
                ListItemView(
                    title: item.title,
                    subTitle: item.subTitle,
                    systemNameImage: "",
                    backgroundColor: ColorSemantic.backgroundTertiary.color,
                    onTapGesture: nil
                )
            }
        }
        .padding(.top, SizeNames.defaultMargin)
        .padding(.horizontal, SizeNames.defaultMargin)
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    PopulationStateViewCoordinator(year: "2022", model: [])
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
