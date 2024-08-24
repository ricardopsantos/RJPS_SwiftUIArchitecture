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
    let haveNavigationStack: Bool
    
    // MARK: - Body & View
    var body: some View {
        if haveNavigationStack {
            NavigationStack(path: $coordinator.navPath) {
                buildScreen(.favoriteEvents)
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .sheet(item: $coordinator.sheetLink, content: buildScreen)
                    .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
            }
        } else {
            buildScreen(.favoriteEvents)
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
                }, onNewLog: { trackerLog in
                    coordinator.sheetLink = .eventLogDetails(model: .init(trackedLog: trackerLog))
                },
                dataBaseRepository: configuration.dataBaseRepository)
            FavoriteEventsView(dependencies: dependencies)
        case .eventLogDetails(model: let model):
            let dependencies: EventLogDetailsViewModel.Dependencies = .init(
                model: model, onCompletion: { _ in
                    
                }, onRouteBack: {},
                dataBaseRepository: configuration.dataBaseRepository)
            EventLogDetailsView(dependencies: dependencies)
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
    
    // MARK: - Auxiliar Attributes
    private let cancelBag: CancelBag = .init()
    @StateObject var locationViewModel: Common.CoreLocationManagerViewModel = .shared
    
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
                locationViewModel.stop()
            }
            .onChange(of: viewModel.favorits) { _ in
                let locationRelevant = !viewModel.favorits.filter({ $0.locationRelevant }).isEmpty
                if locationRelevant {
                    locationViewModel.start()
                } else {
                    locationViewModel.stop()
                }
            }
    }
    
    var content: some View {
        ScrollView {
            Header(text: "Favorite".localizedMissing)
            LazyVStack(spacing: SizeNames.defaultMarginSmall) {
                Spacer()
                ForEach(viewModel.favorits, id: \.self) { model in
                    CounterView(
                        model: model,
                        onChange: { number in
                            Common_Logs.debug(number)
                        },
                        onTapGesture: {
                            viewModel.send(.addNewEvent(trackedEntityId: model.id))
                        })
                }
                .padding(.horizontal, SizeNames.defaultMargin)
                Spacer()
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
    FavoriteEventsViewCoordinator(haveNavigationStack: true)
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
