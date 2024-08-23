//
//  EventsListViewModel.swift
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
import Domain

//
// MARK: - Coordinator
//
struct EventsListViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @EnvironmentObject var coordinatorTab2: RouterViewModel
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage Attributes
    @Environment(\.dismiss) var dismiss
    private let haveNavigationStack = false
    // MARK: - Body & View
    var body: some View {
        if haveNavigationStack {
            NavigationStack(path: $coordinator.navPath) {
                buildScreen(.eventsList)
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .sheet(item: $coordinator.sheetLink, content: buildScreen)
                    .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
            }
        } else {
            buildScreen(.eventsList)
                .sheet(item: $coordinator.sheetLink, content: buildScreen)
                .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
        }
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .eventsList:
            let dependencies: EventsListViewModel.Dependencies = .init(
                model: .init(), onCompletion: { _ in
                }, onSelected: { model in
                    let detailsModel: EventDetailsModel = .init(event: model)
                    coordinatorTab2.navigate(to: .eventDetails(model: detailsModel))
                },
                dataBaseRepository: configuration.dataBaseRepository)
            EventsListView(dependencies: dependencies)
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

struct EventsListView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: EventsListViewModel
    public init(dependencies: EventsListViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onSelected = dependencies.onSelected
    }

    // MARK: - Usage Attributes
    @Environment(\.dismiss) var dismiss
    // @State var someVar = 0

    // MARK: - Auxiliar Attributes
    private let cancelBag: CancelBag = .init()
    private let onSelected: (Model.TrackedEntity) -> Void

    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .templateWith(model: .init()),
            navigationViewModel: .disabled,
            ignoresSafeArea: true,
            background: .linear,
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
        contentV1
    }

    @ViewBuilder
    var contentV2: some View {
        let cascadeEvents = viewModel.events
        List {
            ForEach(0..<cascadeEvents.count, id: \.self) { i in
                let item = cascadeEvents[i]
                ListItemView(
                    title: item.localizedEventName,
                    subTitle: item.localizedEventsCount,
                    systemImage: (item.category.systemImageName, item.category.color),
                    onTapGesture: {
                        onSelected(item)
                    })
                    .padding(.horizontal, -20) // Adjust vertical padding to increase spacing
                    .padding(.vertical, -11 + (SizeNames.defaultMarginSmall / 2))
                    .listRowSeparator(.hidden)
                    .swipeActions {
                        Button(role: .destructive) {
                            if let index = cascadeEvents.firstIndex(of: item) {
                                // items.remove(at: index)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }.padding(.vertical, 11)
                    }
            }
        }
        .background(Color.clear)
        .listStyle(PlainListStyle())
    }

    @ViewBuilder
    var contentV1: some View {
        let sectionA = viewModel.events.filter(\.favorite)
        let sectionB = viewModel.events.filter { !$0.favorite && !$0.archived }
        let sectionC = viewModel.events.filter(\.archived)
        ScrollView {
            LazyVStack {
                HStack(spacing: 0) {
                    Text("Favorits".localizedMissing)
                        .textColor(ColorSemantic.labelPrimary.color)
                        .fontSemantic(.bodyBold)
                    Spacer()
                }
                buildListV1(events: sectionA)
                Divider().padding(.vertical, SizeNames.defaultMarginSmall)
                HStack(spacing: 0) {
                    Text("Regular".localizedMissing)
                        .textColor(ColorSemantic.labelPrimary.color)
                        .fontSemantic(.bodyBold)
                    Spacer()
                }
                buildListV1(events: sectionB)
                Divider().padding(.vertical, SizeNames.defaultMarginSmall)
                HStack(spacing: 0) {
                    Text("Archived".localizedMissing)
                        .textColor(ColorSemantic.labelSecondary.color)
                        .fontSemantic(.bodyBold)
                    Spacer()
                }
                buildListV1(events: sectionC)
                    .opacity(0.5)
                Spacer().padding(.horizontal, SizeNames.defaultMargin)
            }
            .padding(SizeNames.defaultMargin)
        }
    }

    @ViewBuilder
    func buildListV1(events: [Model.TrackedEntity]) -> some View {
        ForEach(events, id: \.self) { item in
            ListItemView(
                title: item.localizedEventName,
                subTitle: item.localizedEventsCount,
                systemImage: (item.category.systemImageName, item.category.color),
                onTapGesture: {
                    onSelected(item)
                })
                .debugBordersDefault()
                .swipeActions {
                    Button(role: .destructive) {
                        if let index = events.firstIndex(of: item) {
                            //  items.remove(at: index)
                            print("item")
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
    }
}

fileprivate extension EventsListView {
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
    EventsListViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
