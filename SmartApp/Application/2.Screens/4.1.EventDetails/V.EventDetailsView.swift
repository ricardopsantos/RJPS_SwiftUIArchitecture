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
    // MARK: - Usage/Auxiliar Attributes
    @EnvironmentObject var coordinatorTab2: RouterViewModel
    @Environment(\.dismiss) var dismiss
    let model: EventDetailsModel
    let haveNavigationStack: Bool

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
                }, onTrackedLogTapped: { trackedLog in
                    coordinator.sheetLink = .eventLogDetails(model: .init(trackedLog: trackedLog))
                },
                dataBaseRepository: configuration.dataBaseRepository)
            EventDetailsView(dependencies: dependencies)
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

struct EventDetailsView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: EventDetailsViewModel
    public init(dependencies: EventDetailsViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onRouteBack = dependencies.onRouteBack
    }

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    private let onRouteBack: () -> Void
    @State var locationSwitchIsOn: Bool = false
    private let cancelBag: CancelBag = .init()
    @StateObject var locationViewModel: Common.CoreLocationManagerViewModel = .shared

    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .eventDetails(model: .init(event: .random(cascadeEvents: []))),
            navigationViewModel: .custom(onBackButtonTap: {
                onRouteBack()
            }, title: "Event Details".localizedMissing),
            ignoresSafeArea: false,
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
            .onChange(of: viewModel.locationRelevant) { locationRelevant in
                DevTools.Log.debug(.valueChanged("\(Self.self)", "locationRelevant", nil), .view)
                if locationRelevant {
                    locationViewModel.start()
                } else {
                    locationViewModel.stop()
                }
            }
    }

    var content: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    detailsView
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
                    Divider()
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
                    archivedAndDeleteView
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
                    Divider()
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
                    addNewView
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
                    listView
                }
                .paddingRight(SizeNames.size_1.cgFloat)
                .paddingLeft(SizeNames.size_1.cgFloat)
            }.padding(SizeNames.defaultMargin)
            if viewModel.confirmationSheetType != nil {
                confirmationSheet
            }
            VStack(spacing: 0) {
                Text(viewModel.userMessage.text)
                    .multilineTextAlignment(.center)
                    .textColor(viewModel.userMessage.color.color)
                    .fontSemantic(.body)
                    .shadow(radius: SizeNames.shadowRadiusRegular)
                    .animation(.linear(duration: Common.Constants.defaultAnimationsTime), value: viewModel.userMessage.text)
                    .onTapGesture {
                        viewModel.userMessage.text = ""
                    }
                Spacer()
            }
        }
    }

    var detailsView: some View {
        LazyVStack(spacing: 0) {
            CustomTitleAndCustomTextFieldWithBinding(
                title: "Name".localizedMissing,
                placeholder: "Name".localizedMissing,
                inputText: $viewModel.name,
                accessibility: .undefined) { newValue in
                    viewModel.send(.userDidChangedName(value: newValue))
                }

            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            CustomTitleAndCustomTextFieldWithBinding(
                title: "Info".localizedMissing,
                placeholder: "Info".localizedMissing,
                inputText: $viewModel.info,
                accessibility: .undefined) { newValue in
                    viewModel.send(.userDidChangedInfo(value: newValue))
                }

            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            ToggleWithBinding(
                title: "Favorite".localizedMissing,
                isOn: $viewModel.favorite,
                onChanged: { newValue in
                    viewModel.send(.userDidChangedFavorite(value: newValue))
                })

            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            ToggleWithBinding(
                title: "Grab user location when add new event".localizedMissing,
                isOn: $viewModel.locationRelevant,
                onChanged: { newValue in
                    viewModel.send(.userDidChangedLocationRelevant(value: newValue))
                })

            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            CategoryPickerView(selected: viewModel.category) { newValue in
                viewModel.send(.userDidChangedEventCategory(value: newValue))
            }

            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            SoundPickerView(selected: $viewModel.soundEffect) { newValue in
                viewModel.send(.userDidChangedSoundEffect(value: newValue))
            }
        }
        .paddingRight(SizeNames.size_1.cgFloat)
        .paddingLeft(SizeNames.size_1.cgFloat)
    }

    var addNewView: some View {
        TextButton(
            onClick: {
                AnalyticsManager.shared.handleButtonClickEvent(
                    buttonType: .primary,
                    label: "Add new",
                    sender: "\(Self.self)")
                viewModel.send(.addNew)
            },
            text: "Add new".localizedMissing,
            alignment: .center,
            style: .secondary,
            background: .primary,
            accessibility: .undefined)
    }

    var archivedAndDeleteView: some View {
        Group {
            ToggleWithState(
                title: "Archived".localizedMissing,
                isOn: viewModel.archived,
                onChanged: { newValue in
                    viewModel.send(.userDidChangedArchived(value: newValue))
                })
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            TextButton(
                onClick: {
                    AnalyticsManager.shared.handleButtonClickEvent(
                        buttonType: .primary,
                        label: "Delete",
                        sender: "\(Self.self)")
                    viewModel.send(.delete(confirmed: false))
                },
                text: "Delete Event".localizedMissing,
                alignment: .center,
                style: .secondary,
                background: .danger,
                accessibility: .undefined)
        }
    }

    var listView: some View {
        Group {
            if let logs = viewModel.logs, !logs.isEmpty {
                LazyVStack {
                    ForEach(logs, id: \.self) { model in
                        ListItemView(
                            title: model.title,
                            subTitle: model.value,
                            systemImage: ("", .clear),
                            onTapGesture: {
                                viewModel.send(.usedDidTappedLogEvent(trackedLogId: model.id))
                            })
                    }
                }
            } else {
                EmptyView()
            }
        }
    }

    var confirmationSheet: some View {
        @State var isOpen = Binding<Bool>(
            get: { viewModel.confirmationSheetType != nil },
            set: { if !$0 { viewModel.confirmationSheetType = nil } })
        return ConfirmationSheetV2(
            isOpen: isOpen,
            title: viewModel.confirmationSheetType!.title,
            subTitle: viewModel.confirmationSheetType!.subTitle,
            confirmationAction: {
                guard let sheetType = viewModel.confirmationSheetType else {
                    return
                }
                switch sheetType {
                case .delete:
                    viewModel.send(.delete(confirmed: true))
                }
            })
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    EventDetailsViewCoordinator(
        model: .init(event: .random(cascadeEvents: [
            .random,
            .random
        ])), haveNavigationStack: false)
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
        .environmentObject(AuthenticationViewModel.defaultForPreviews)
}
#endif
