//
//  EventsCalendarViewModel.swift
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
struct EventsCalendarViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @EnvironmentObject var coordinatorTab3: RouterViewModel
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage Attributes
    @Environment(\.dismiss) var dismiss
    let haveNavigationStack: Bool
    // MARK: - Body & View
    var body: some View {
        if haveNavigationStack {
            NavigationStack(path: $coordinator.navPath) {
                buildScreen(.calendar)
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .sheet(item: $coordinator.sheetLink, content: buildScreen)
                    .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
            }
        } else {
            buildScreen(.calendar)
                .sheet(item: $coordinator.sheetLink, content: buildScreen)
                .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
        }
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .calendar:
            let dependencies: EventsCalendarViewModel.Dependencies = .init(
                model: .init(), onSelected: { model in
                    let detailsModel: EventDetailsModel = .init(event: model)
                    coordinatorTab3.navigate(to: .eventDetails(model: detailsModel))
                },
                dataBaseRepository: configuration.dataBaseRepository)
            EventsCalendarView(dependencies: dependencies)
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

struct EventsCalendarView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: EventsCalendarViewModel
    public init(dependencies: EventsCalendarViewModel.Dependencies) {
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
            appScreen: .calendar,
            navigationViewModel: .disabled,
            ignoresSafeArea: false,
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

    @ViewBuilder
    var content: some View {
        let sectionA = viewModel.events.filter(\.favorite)
        let sectionB = viewModel.events.filter { !$0.favorite && !$0.archived }
        let sectionC = viewModel.events.filter(\.archived)
        ScrollView {
            LazyVStack(spacing: 0) {
                CalendarView(
                    currentDate: .constant(Date()),
                    selectedDay: $viewModel.selectedDay,
                    onSelectedDay: { day in
                        viewModel.send(.loadEventsForDay(value: day))
                    },
                    onSelectedMonth: { month in
                        viewModel.send(.loadEventForMonth(value: month))
                    })
                Divider().padding(.vertical, SizeNames.defaultMarginSmall)
                HStack(spacing: 0) {
                    Text("Favorits".localizedMissing)
                        .textColor(ColorSemantic.labelPrimary.color)
                        .fontSemantic(.bodyBold)
                    Spacer()
                }
                buildList(events: sectionA)
                Divider().padding(.vertical, SizeNames.defaultMarginSmall)
                HStack(spacing: 0) {
                    Text("Others".localizedMissing)
                        .textColor(ColorSemantic.labelPrimary.color)
                        .fontSemantic(.bodyBold)
                    Spacer()
                }
                buildList(events: sectionB)
                Divider().padding(.vertical, SizeNames.defaultMarginSmall)
                HStack(spacing: 0) {
                    Text("Archived".localizedMissing)
                        .textColor(ColorSemantic.labelSecondary.color)
                        .fontSemantic(.bodyBold)
                    Spacer()
                }
                buildList(events: sectionC)
                    .opacity(0.5)
                Spacer().padding(.vertical, SizeNames.defaultMarginSmall)
            }
        }
    }

    @ViewBuilder
    func buildList(events: [Model.TrackedEntity]) -> some View {
        ForEach(events, id: \.self) { item in
            ListItemView(
                title: item.localizedEventName,
                subTitle: item.localizedEventsCount,
                systemImage: (item.category.systemImageName, item.category.color),
                onTapGesture: {
                    onSelected(item)
                }).padding(.vertical, SizeNames.defaultMarginSmall / 2)
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    EventsCalendarViewCoordinator(haveNavigationStack: true)
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
