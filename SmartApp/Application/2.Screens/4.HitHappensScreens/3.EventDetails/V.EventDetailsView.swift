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
    @EnvironmentObject var coordinatorTab2: RouterViewModel
    @Environment(\.dismiss) var dismiss
    let model: EventDetailsModel
    private let haveNavigationStack: Bool = false
    // MARK: - Body & View
    var body: some View {
        if !haveNavigationStack {
            buildScreen(.eventDetails(model: model))
                .sheet(item: $coordinator.sheetLink, content: buildScreen)
                .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
        } else {
            NavigationStack(path: $coordinator.navPath) {
                buildScreen(.eventDetails(model: model))
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .sheet(item: $coordinator.sheetLink, content: buildScreen)
                    .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
            }
        }
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .eventDetails(model: let model):
            let dependencies: EventDetailsViewModel.Dependencies = .init(
                model: model, onCompletion: { _ in }, onRouteBack: {
                    coordinatorTab2.navigateBack()
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
            VStack {
                detailsView
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
                listView
            }
        }.padding(SizeNames.defaultMargin)
    }

    var detailsView: some View {
        VStack(spacing: SizeNames.defaultMarginSmall) {
            TitleAndValueView(
                title: "Name".localizedMissing,
                value: viewModel.event?.name ?? "")
                .debugBordersDefault()
            TitleAndValueView(
                title: "Info".localizedMissing,
                value: viewModel.event?.info ?? "")
            .debugBordersDefault()

            TitleAndValueView(
                title: "Color".localizedMissing,
                value: viewModel.event?.color.rgbString ?? "")
            .debugBordersDefault()

            TitleAndValueView(
                title: "Sound".localizedMissing,
                value: viewModel.event?.sound.name ?? "")
            .debugBordersDefault()

            ToggleWithState(
                title: "Location relevant",
                isOn: viewModel.event?.locationRelevant ?? false,
                onChanged: { newValue in
                    viewModel.send(.userDidChangedLocationRelevant(value: newValue))
                })
                .paddingRight(SizeNames.size_1.cgFloat)
                .debugBordersDefault()

            // Picker with closure
            CategoryPickerView(selected: (viewModel.event?.category ?? .none).localized) { newValue in
                viewModel.send(.userDidChangedEventCategory(value: newValue))
            }
            .debugBordersDefault()

            // Picker with binding
            SoundPickerView(selected: $viewModel.soundEffect) { newValue in
                viewModel.send(.userDidChangedSoundEffect(value: newValue))
            }
            .debugBordersDefault()

        }
    }

    var listView: some View {
        Group {
            if let cascadeEvents = viewModel.event?.cascadeEvents {
                LazyVStack(spacing: SizeNames.defaultMarginSmall) {
                    ForEach(cascadeEvents, id: \.self) { model in
                        ListItemView(
                            title: model.localizedListItemTitle,
                            subTitle: model.localizedListItemValue,
                            onTapGesture: {
                                //     onSelected(model)
                            })
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
    EventDetailsViewCoordinator(
        model: .init(event: .random(cascadeEvents: [.random, .random])))
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
        .environmentObject(AuthenticationViewModel.defaultForPreviews)
}
#endif
