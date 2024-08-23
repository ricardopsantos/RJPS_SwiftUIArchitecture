//
//  EventLogDetailsViewModel.swift
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
struct EventLogDetailsViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage Attributes
    @EnvironmentObject var coordinatorTab2: RouterViewModel
    @Environment(\.dismiss) var dismiss
    let model: EventLogDetailsModel
    private let haveNavigationStack: Bool = false
    // MARK: - Body & View
    var body: some View {
        if !haveNavigationStack {
            buildScreen(.eventLogDetails(model: model))
                .sheet(item: $coordinator.sheetLink, content: buildScreen)
                .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
        } else {
            NavigationStack(path: $coordinator.navPath) {
                buildScreen(.eventLogDetails(model: model))
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .sheet(item: $coordinator.sheetLink, content: buildScreen)
                    .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
            }
        }
    }
    
    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .eventLogDetails(model: let model):
            let dependencies: EventLogDetailsViewModel.Dependencies = .init(
                model: model, onCompletion: { _ in }, onRouteBack: {
                    coordinatorTab2.navigateBack()
                },
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

struct EventLogDetailsView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: EventLogDetailsViewModel
    public init(dependencies: EventLogDetailsViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onRouteBack = dependencies.onRouteBack
    }
    
    // MARK: - Usage Attributes
    @Environment(\.dismiss) var dismiss
    private let onRouteBack: () -> Void
    @State var locationSwitchIsOn: Bool = false
    
    // MARK: - Auxiliar Attributes
    private let cancelBag: CancelBag = .init()

    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .templateWith(model: .init()),
            navigationViewModel: .custom(onBackButtonTap: {
                onRouteBack()
            }, title: "Event Details".localizedMissing),
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
                Header(text: "Log details".localizedMissing)
                CustomTitleAndCustomTextFieldV2(
                    title: "Note".localizedMissing,
                    placeholder: "Note".localizedMissing,
                    accessibility: .undefined) { newValue in
                        viewModel.send(.userDidChangedNote(value: newValue))
                    }
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                TextButton(
                    onClick: {
                        viewModel.send(.delete)
                    },
                    text: "Delete".localizedMissing,
                    alignment: .center,
                    style: .secondary,
                    background: .dangerColor,
                    accessibility: .undefined)
            }
            .paddingRight(SizeNames.size_1.cgFloat)
            .paddingLeft(SizeNames.size_1.cgFloat)
        }.padding(SizeNames.defaultMargin)
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    EventLogDetailsViewCoordinator(model: .init(trackedLog: .random))
    .environmentObject(AppStateViewModel.defaultForPreviews)
    .environmentObject(ConfigurationViewModel.defaultForPreviews)
    .environmentObject(AuthenticationViewModel.defaultForPreviews)
}
#endif
