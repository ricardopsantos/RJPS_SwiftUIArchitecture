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
    @StateObject var router = RouterViewModel()
    // MARK: - Usage Attributes
    let year: String

    // MARK: - Body & View
    var body: some View {
        NavigationStack(path: $router.navPath) {
            buildScreen(.populationStates(year: year, model: []))
                .navigationDestination(for: AppScreen.self, destination: buildScreen)
                .sheet(item: $router.sheetLink, content: buildScreen)
                .fullScreenCover(item: $router.coverLink, content: buildScreen)
        }
        .environmentObject(router)
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .populationStates(year: let year, model: let model):
            let dependencies: PopulationStateViewModel.Dependencies = .init(
                model: model, year: year, didSelected: { some in
                    DevTools.Log.debug("\(some)", .generic)
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

struct PopulationStateView: View {
    // MARK: - ViewProtocol

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var router: RouterViewModel
    @StateObject var viewModel: PopulationStateViewModel
    let didSelected: (ModelDto.PopulationStateDataResponse) -> Void
    public init(dependencies: PopulationStateViewModel.Dependencies) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.didSelected = dependencies.didSelected
    }

    // MARK: - Body & View
    var body: some View {
        if Common_Utils.onSimulator {
            // swiftlint:disable redundant_discardable_let
            let _ = Self._printChanges()
            // swiftlint:enable redundant_discardable_let
        }
        BaseView.with(
            sender: "\(Self.self)",
            appScreen: .populationStates(year: "", model: []),
            navigationViewEmbed: false,
            scrollViewEmbed: false,
            ignoresSafeArea: true,
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
        VStack(spacing: 0) {
            Header(text: viewModel.title)
                .padding(.horizontal, SizeNames.defaultMargin)
                .offset(.init(width: 0, height: -SizeNames.defaultMargin))
            ScrollView(showsIndicators: false) {
                listView
            }
        }
        .frame(maxWidth: .infinity)
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension PopulationStateView {
    var listView: some View {
        VStack(spacing: SizeNames.defaultMargin) {
            ForEach(Array(viewModel.model.enumerated()), id: \.element) { _, item in
                ListItemView(
                    title: item.title,
                    subTitle: item.subTitle,
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
