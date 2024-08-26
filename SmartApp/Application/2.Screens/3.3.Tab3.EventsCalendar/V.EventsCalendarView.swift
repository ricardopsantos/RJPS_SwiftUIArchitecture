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
    // MARK: - Usage/Auxiliar Attributes
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
                model: .init(), onTrackedLogTapped: { trackedLog in
                    coordinator.sheetLink = .eventLogDetails(model: .init(trackedLog: trackedLog))
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
    }

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    private let cancelBag: CancelBag = .init()

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
        ScrollView {
            LazyVStack(spacing: 0) {
                CalendarView(
                    currentDate: $viewModel.selectedMonth,
                    selectedDay: $viewModel.selectedDay,
                    onSelectedDay: { day in
                        viewModel.send(.loadEvents(fullMonth: false, value: day))
                    },
                    onSelectedMonth: { month in
                            viewModel.send(.loadEvents(fullMonth: true, value: month))
                    })
                Divider().padding(.vertical, SizeNames.defaultMarginSmall)
                listTitle
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                listView
            }
        }
    }
    
    var listTitle: some View {
        Group {
            if let logs = viewModel.logs, !logs.isEmpty {
                if let selectedDay = viewModel.selectedDay {
                    Text("\(logs.count) event(s) on \(selectedDay.dateStyleShort)")
                        .fontSemantic(.body)
                        .textColor(ColorSemantic.labelPrimary.color)
                } else {
                    Text("\(logs.count) event(s) on \(viewModel.selectedMonth.monthAndYear)".localizedMissing)
                        .fontSemantic(.body)
                        .textColor(ColorSemantic.labelPrimary.color)
                }
            }
            else {
                if let selectedDay = viewModel.selectedDay {
                    Text("No events for \(selectedDay.dateStyleShort)".localizedMissing)
                        .fontSemantic(.body)
                        .textColor(ColorSemantic.labelPrimary.color)
                } else  {
                    Text("No events for \(viewModel.selectedMonth.monthAndYear)".localizedMissing)
                        .fontSemantic(.body)
                        .textColor(ColorSemantic.labelPrimary.color)
                }
            }
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
