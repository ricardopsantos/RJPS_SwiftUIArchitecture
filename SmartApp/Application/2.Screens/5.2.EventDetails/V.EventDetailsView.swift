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
    @State private var showPopover: Bool = false
    @State private var selectedItem: String?

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
                archivedAndDeleteView
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                Divider()
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                listView
            }
            .paddingRight(SizeNames.size_1.cgFloat)
            .paddingLeft(SizeNames.size_1.cgFloat)
        }.padding(SizeNames.defaultMargin)
            .popover(isPresented: $showPopover) {
                          popoverView(for: selectedItem)
                      }
    }
    
    var detailsView: some View {
        LazyVStack(spacing: SizeNames.defaultMarginSmall) {
            CustomTitleAndCustomTextFieldV2(
                title: "Name".localizedMissing,
                placeholder: "Name".localizedMissing,
                accessibility: .undefined) { newValue in
                    viewModel.send(.userDidChangedName(value: newValue))
                }
            CustomTitleAndCustomTextFieldV2(
                title: "Info".localizedMissing,
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
    
    var archivedAndDeleteView: some View {
        Group {
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
                accessibility: .undefined)
        }
    }
    
    
    var listView: some View {
        listViewV1
    }
    
    var listViewV1: some View {
        Group {
            if let cascadeEvents = viewModel.cascadeEvents, !cascadeEvents.isEmpty {
                LazyVStack {
                    ForEach(cascadeEvents, id: \.self) { model in
                        ListItemView(
                            title: model.title,
                            subTitle: model.value,
                            systemImage: ("", .clear),
                            onTapGesture: {
                                selectedItem = model.id
                                showPopover = true
                            })
                        .debugBordersDefault()
                        .listRowSeparator(.hidden)
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private func popoverView(for item: String?) -> some View {
           VStack(spacing: 20) {
               Text("Options for \(item ?? "Item")")
                   .fontSemantic(.title1)
               
               Button("Delete") {
                   // Handle delete action
                   print("Delete \(item ?? "Item")")
                   self.showPopover = false
               }
               
               Button("Details") {
                   // Handle details action
                   print("Details for \(item ?? "Item")")
                   self.showPopover = false
               }
               
               Button("Cancel") {
                   // Handle cancel action
                   self.showPopover = false
               }
           }
           .padding()
           .frame(width: 200)
       }
    
    var listViewV2: some View {
        Group {
            if let cascadeEvents = viewModel.cascadeEvents, !cascadeEvents.isEmpty {
                List {
                    ForEach(cascadeEvents, id: \.self) { item in
                        ListItemView(
                            title: item.title,
                            subTitle: item.value,
                            systemImage: ("", .clear),
                            onTapGesture: {
                                // Handle tap gesture
                            })
                        .background(Color.red)
                        .debugBordersDefault()
                        .listRowSeparator(.hidden)
                        .swipeActions {
                            Button(role: .destructive) {
                                if let index = cascadeEvents.firstIndex(of: item) {
                                    // items.remove(at: index)
                                    self.selectedItem = item.id
                                                       self.showPopover = true
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }.padding(.vertical, 11)
                        }
                    }
                }
                .listStyle(.inset)
                .listRowSpacing(-12)
                .frame(minHeight: screenHeight / 2)
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
        model: .init(event: .random(cascadeEvents: [
            .random,
            .random,
            .random,
            .random,
            .random,
            .random,
            .random,
            .random,
            .random
        ])))
    .environmentObject(AppStateViewModel.defaultForPreviews)
    .environmentObject(ConfigurationViewModel.defaultForPreviews)
    .environmentObject(AuthenticationViewModel.defaultForPreviews)
}
#endif
