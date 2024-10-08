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
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage Attributes
    @EnvironmentObject var coordinatorTab2: RouterViewModel

    // MARK: - Body & View
    var body: some View {
        buildScreen(.populationNation)
            .sheet(item: $coordinator.sheetLink, content: buildScreen)
            .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .populationNation:
            let dependencies: PopulationNationViewModel.Dependencies = .init(
                model: .init(),
                dataUSAService: configuration.dataUSAService,
                onSelected: { item in
                    coordinatorTab2.navigate(to: .populationStates(year: item.year, model: []))
                }
            )
            PopulationNationView(dependencies: dependencies)
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
    @StateObject var viewModel: PopulationNationViewModel
    public init(dependencies: PopulationNationViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onSelected = dependencies.onSelected
    }

    // MARK: - Usage Attributes
    @Environment(\.dismiss) var dismiss
    @StateObject var networkMonitorViewModel: Common.NetworkMonitorViewModel = .shared

    // MARK: - Auxiliar Attributes
    private let onSelected: (PopulationNationModel) -> Void

    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .populationNation,
            navigationViewModel: .disabled,
            background: .defaultBackground,
            loadingModel: viewModel.loadingModel,
            alertModel: viewModel.alertModel,
            networkStatus: networkMonitorViewModel.networkStatus
        ) {
            content
        }.onAppear {
            viewModel.send(action: .didAppear)
        }.onDisappear {
            viewModel.send(action: .didDisappear)
        }
        .onChange(of: networkMonitorViewModel.networkStatus) { networkStatus in
            switch networkStatus {
            case .unknown, .internetConnectionAvailable, .internetConnectionLost:
                ()
            case .internetConnectionRecovered:
                viewModel.send(action: .getPopulationData(cachePolicy: .load))
            }
        }
    }

    var content: some View {
        VStack(spacing: 0) {
            Header(text: viewModel.title).padding(.horizontal, SizeNames.defaultMargin)
            ScrollView(showsIndicators: false) {
                listView
            }
            .accessibility(identifier: Accessibility.scrollView.identifier)
            .refreshable {
                if Common_Utils.true {
                    // Small anti-pattern reason:
                    // The reason that we use a custom viewModel function instead of
                    // calling `viewModel.send` is because the `refreshable` view modifier
                    // will stops after the await (else wont stop)
                    _ = await viewModel.getPopulationData(cachePolicy: .load, action: nil)
                } else {
                    viewModel.send(action: .getPopulationData(cachePolicy: .load))
                }
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
        LazyVStack(spacing: SizeNames.defaultMarginSmall) {
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

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    PopulationNationViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
