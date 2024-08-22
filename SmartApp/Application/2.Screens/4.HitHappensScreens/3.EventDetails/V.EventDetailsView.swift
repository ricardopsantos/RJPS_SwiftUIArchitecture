//
//  EventDetailsViewModel.swift
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
struct EventDetailsViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage Attributes
    @Environment(\.dismiss) var dismiss

    // MARK: - Body & View
    var body: some View {
        NavigationStack(path: $coordinator.navPath) {
            buildScreen(.eventDetails)
                .navigationDestination(for: AppScreen.self, destination: buildScreen)
                .sheet(item: $coordinator.sheetLink, content: buildScreen)
                .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
        }
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .eventDetails:
            let dependencies: EventDetailsViewModel.Dependencies = .init(
                model: .init(), onCompletion: { _ in
                },
                dataBaseRepository: configuration.dataBaseRepository)
            EventDetailsView(dependencies: dependencies)
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

struct EventDetailsView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: EventDetailsViewModel
    public init(dependencies: EventDetailsViewModel.Dependencies) {
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
            listView
        }.padding(SizeNames.defaultMargin)
    }
    
    var detailsView: some View {
        VStack(spacing: 0) {
            TitleAndValueView(title: "Name", value: viewModel.event?.name ?? "")
            TitleAndValueView(title: "Name", value: viewModel.event?.info ?? "")
            TitleAndValueView(title: "Color", value: viewModel.event?.color.rgbString ?? "")
            TitleAndValueView(title: "Sound", value: viewModel.event?.sound ?? "")
        }
    }
    
    var listView: some View {
        Group {
            if let cascadeEvents = viewModel.event?.cascadeEvents {
                VStack(spacing: SizeNames.defaultMarginSmall) {
                    ForEach(cascadeEvents, id: \.self) { model in
                        ListItemView(
                            title: "title",
                            subTitle: "subTitle",
                            onTapGesture: {
                                //     onSelected(model)
                            }
                        )
                        .debugBordersDefault()
                    }
                    Spacer()
                        .padding(.horizontal, SizeNames.defaultMargin)
                }
            } else {
                EmptyView()
            }
        }

    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    EventDetailsViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
        .environmentObject(AuthenticationViewModel.defaultForPreviews)
}
#endif

