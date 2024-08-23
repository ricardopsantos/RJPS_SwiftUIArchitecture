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
            LazyVStack(spacing: SizeNames.defaultMarginSmall) {
                detailsView
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                Divider()
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                ToggleWithState(
                    title: "Archived".localizedMissing,
                    isOn: viewModel.event?.archived ?? false,
                    onChanged: { newValue in
                        viewModel.send(.userDidChangedArchived(value: newValue))
                    })
                    .debugBordersDefault()
                TextButton(
                    onClick: {
                        viewModel.send(.deleteTrackedEntity)
                    },
                    text: "Delete Event".localizedMissing,
                    alignment: .center,
                    style: .secondary,
                    background: .dangerColor,
                    accessibility: .undefined
                )
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                Divider()
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                listView
            }
            .paddingRight(SizeNames.size_1.cgFloat)
            .paddingLeft(SizeNames.size_1.cgFloat)
        }.padding(SizeNames.defaultMargin)
    }

    var detailsView: some View {
        VStack(spacing: SizeNames.defaultMarginSmall) {
            CustomTitleAndCustomTextFieldV2(title: "Name".localizedMissing,
                                            placeholder: "Name".localizedMissing,
                                            accessibility: .undefined) { newValue in
                viewModel.send(.userDidChangedName(value: newValue))
            }
            CustomTitleAndCustomTextFieldV2(title: "Info".localizedMissing,
                                            placeholder: "Info".localizedMissing,
                                            accessibility: .undefined) { newValue in
                viewModel.send(.userDidChangedInfo(value: newValue))
            }

            ToggleWithBinding(
                title: "Favorite".localizedMissing,
                isOn: $viewModel.favorite,
                onChanged: { newValue in
                    viewModel.send(.userDidChangedFavorite(value: newValue))
                })
                .debugBordersDefault()

            
            ToggleWithState(
                title: "Location relevant".localizedMissing,
                isOn: viewModel.event?.locationRelevant ?? false,
                onChanged: { newValue in
                    viewModel.send(.userDidChangedLocationRelevant(value: newValue))
                })
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
        .paddingRight(SizeNames.size_1.cgFloat)
        .paddingLeft(SizeNames.size_1.cgFloat)
    }

    var listView: some View {
        Group {
            if let cascadeEvents = viewModel.event?.cascadeEvents {
                LazyVStack(spacing: SizeNames.defaultMarginSmall) {
                    ForEach(cascadeEvents, id: \.self) { model in
                        ListItemView(
                            title: model.localizedListItemTitle,
                            subTitle: model.localizedListItemValue,
                            systemImage: ("", .clear),
                            onTapGesture: {
                                //     onSelected(model)
                            })
                        .swipeActions {
                            Button(role: .destructive) {
                                if let index = cascadeEvents.firstIndex(of: model) {
                                    print("asd")
                                   // items.remove(at: index)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
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
