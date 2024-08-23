//
//  FavoriteEventsViewModel.swift
//  Common
//
//  Created by Ricardo Santos on 22/08/24.
//

import Foundation
import SwiftUI
//
import DevTools
import Common
import DesignSystem

//
// MARK: - Coordinator
//
struct FavoriteEventsViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage Attributes
    @Environment(\.dismiss) var dismiss

    // MARK: - Body & View
    var body: some View {
        NavigationStack(path: $coordinator.navPath) {
            buildScreen(.favoriteEvents)
                .navigationDestination(for: AppScreen.self, destination: buildScreen)
                .sheet(item: $coordinator.sheetLink, content: buildScreen)
                .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
        }
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .favoriteEvents:
            let dependencies: FavoriteEventsViewModel.Dependencies = .init(
                model: .init(), onCompletion: { _ in
                },
                dataBaseRepository: configuration.dataBaseRepository)
            FavoriteEventsView(dependencies: dependencies)
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

struct FavoriteEventsView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: FavoriteEventsViewModel
    public init(dependencies: FavoriteEventsViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
    }

    // MARK: - Usage Attributes
    @Environment(\.dismiss) var dismiss
    // @State var someVar = 0
    // @StateObject var networkMonitorViewModel: Common.NetworkMonitorViewModel = .shared

    // MARK: - Auxiliar Attributes
    private let cancelBag: CancelBag = .init()

    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .templateWith(model: .init()),
            navigationViewModel: .disabled,
            ignoresSafeArea: true,
            background: .defaultBackground,
            loadingModel: viewModel.loadingModel,
            alertModel: viewModel.alertModel,
            networkStatus: nil) {
                content
            }.onAppear {
                viewModel.send(.didAppear)
            }.onDisappear {
                viewModel.send(.didDisappear)
            }
    }

    var content: some View {
        ScrollView {
            LazyVStack(spacing: SizeNames.defaultMarginSmall) {
                ForEach(viewModel.favorits, id: \.self) { model in
                    CounterView(
                        model: model,
                        onChange: { number in
                            Common_Logs.debug(number)
                        },
                        onTapGesture: {
                            viewModel.send(.addNewEvent(trackedEntityId: model.id))
                        })
                        .debugBordersDefault()
                }
                .padding(.horizontal, SizeNames.defaultMargin)
            }
        }
    }
}

fileprivate extension FavoriteEventsView {
    @ViewBuilder
    var routingView: some View {
        EmptyView()
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    FavoriteEventsViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
        .environmentObject(AuthenticationViewModel.defaultForPreviews)
}
#endif
