//
//  PopulationNationView.swift
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
struct PopulationNationViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var router = RouterViewModel()
    // MARK: - Usage Attributes

    // MARK: - Body & View
    var body: some View {
        NavigationStack(path: $router.navPath) {
            buildScreen(.populationNation)
                .navigationDestination(for: AppScreen.self, destination: buildScreen)
                .sheet(item: $router.sheetLink, content: buildScreen)
                .fullScreenCover(item: $router.coverLink, content: buildScreen)
        }
        .environmentObject(router)
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .populationNation:
            let dependencies: PopulationNationViewModel.Dependencies = .init(
                model: .init(), dataUSAService: configuration.dataUSAService, onSelected: { item in
                        print(item)
                    router.navigate(to: AppScreen.populationStates(year: item.year, model: []))
                }
            )
            PopulationNationView(dependencies: dependencies)
        case .populationStates(year: let year, _):
            let dependencies: PopulationStateViewModel.Dependencies = .init(
                model: .init(),
                year: year,
                onRouteBack: {
                    router.navigateBack()
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

struct PopulationNationView: View, ViewProtocol {
    // MARK: - ViewProtocol

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var router: RouterViewModel
    let onSelected: (PopulationNationModel)->()
    @StateObject var viewModel: PopulationNationViewModel
    public init(dependencies: PopulationNationViewModel.Dependencies) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        onSelected = dependencies.onSelected
    }

    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .populationNation,
            navigationViewModel: .disabled,
            background: .default,
            loadingModel: viewModel.loadingModel,
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
            Header(text: viewModel.title).padding(.horizontal, SizeNames.defaultMargin)
            ScrollView(showsIndicators: false) {
                listView
            }
            .refreshable {
                viewModel.send(action: .getPopulationData(cachePolicy: .load))
            }.padding()
        }
        .frame(maxWidth: .infinity)
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension PopulationNationView {
    var listView: some View {
        VStack(spacing: SizeNames.defaultMarginSmall) {
            ForEach(Array(viewModel.model.enumerated()), id: \.element) { index, item in
                ListItemView(
                    title: item.title,
                    subTitle: item.subTitle,
                    backgroundColor: ColorSemantic.backgroundTertiary.color,
                    onTapGesture: {
                        let label = "Taped index \(index): Year \(item.year)"
                        AnalyticsManager.shared.handleListItemTapEvent(label: label, sender: "\(Self.self)")
                        onSelected(item)
                    }
                )
            }
        }
    }
}

#Preview {
    PopulationNationViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
