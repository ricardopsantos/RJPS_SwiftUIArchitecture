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
    let year: String

    // MARK: - Body & View
    var body: some View {
        NavigationStack(path: $coordinator.navPath) {
            buildScreen(.populationStates(year: year, model: []))
                .navigationDestination(for: AppScreen.self, destination: buildScreen)
                .sheet(item: $coordinator.sheetLink, content: buildScreen)
                .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
        }
        // .environmentObject(router)
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .populationStates(year: let year, model: let model):
            let dependencies: PopulationStateViewModel.Dependencies = .init(
                model: model, year: year,
                onRouteBack: {
                    coordinator.navigateBack()
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
    // @EnvironmentObject var router: RouterViewModel
    @StateObject var viewModel: PopulationStateViewModel
    // MARK: - Usage Attributes
    private let onRouteBack: () -> Void
    public init(dependencies: PopulationStateViewModel.Dependencies) {
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
            appScreen: .populationStates(year: "", model: []),
            navigationViewModel: .custom(onBackButtonTap: {
                onRouteBack()
            }, title: viewModel.title),
            background: .linear,
            loadingModel: viewModel.loadingModel,
            alertModel: viewModel.alertModel
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
        VStack(spacing: SizeNames.defaultMarginSmall) {
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

#Preview {
    PopulationStateViewCoordinator(year: "2022")
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
