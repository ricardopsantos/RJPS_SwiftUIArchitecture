//
//  EventsCalendarViewModel.swift
//  Common
//
//  Created by Ricardo Santos on 22/08/24.
//

import Foundation
import SwiftUI
//
import Domain
import Common
import Core

//
// MARK: - Model
//

public struct EventsCalendarModel: Equatable, Hashable, Sendable {
    let message: String

    init(message: String = "") {
        self.message = message
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension EventsCalendarViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case loadEvents(fullMonth: Bool, value: Date?)
        case usedDidTappedLogEvent(trackedLogId: String)
    }

    struct Dependencies {
        let model: EventsCalendarModel
        let onTrackedLogTapped: (Model.TrackedLog) -> Void
        let dataBaseRepository: DataBaseRepositoryProtocol
    }
}

//
// MARK: - ViewModel
//
class EventsCalendarViewModel: BaseViewModel {
    // MARK: - Usage/Auxiliar Attributes
    @Published private(set) var message: String = ""
    @Published private(set) var events: [Model.TrackedEntity] = []
    @Published private(set) var logs: [CascadeEventListItem]?
    @Published var selectedDay: Date?
    @Published var selectedMonth: Date = .now
    @Published var eventsForDay: [Date: [Color]] = [:]
    private let cancelBag = CancelBag()
    private let dataBaseRepository: DataBaseRepositoryProtocol?
    private let onTrackedLogTapped: (Model.TrackedLog) -> Void
    public init(dependencies: Dependencies) {
        self.dataBaseRepository = dependencies.dataBaseRepository
        self.message = dependencies.model.message
        self.onTrackedLogTapped = dependencies.onTrackedLogTapped
        super.init()
        startListeningDBChanges()
    }

    func send(_ action: Actions) {
        switch action {
        case .didAppear:
            send(.loadEvents(fullMonth: true, value: Date()))
        case .didDisappear: ()
        case .loadEvents(fullMonth: let fullMonth, let value):
            Common.ExecutionControlManager.debounce(operationId: "\(Self.self)|\(#function)") { [weak self] in
                Task { [weak self] in
                    guard let self = self else { return }
                    let min: Date!
                    let max: Date!
                    if let value = value, !fullMonth {
                        min = value.beginningOfDay ?? Date().beginningOfDay
                        max = value.endOfDay ?? Date().endOfDay
                    } else {
                        min = value?.beginningOfMonth ?? selectedMonth.beginningOfMonth
                        max = value?.endOfMonth ?? selectedMonth.endOfMonth
                    }
                    if let records = self.dataBaseRepository?.trackedLogGetAll(min: min, maxDate: max, cascade: true) {
                        updateUI(logs: records, canUpdateEventsForDay: fullMonth)
                    }
                }
            }
        case .usedDidTappedLogEvent(trackedLogId: let trackedLogId):
            Task { [weak self] in
                guard let self = self else { return }
                if let trackedLog = dataBaseRepository?.trackedLogGet(trackedLogId: trackedLogId, cascade: true) {
                    onTrackedLogTapped(trackedLog)
                }
            }
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension EventsCalendarViewModel {
    func updateUI(logs trackedLogs: [Model.TrackedLog], canUpdateEventsForDay: Bool) {
        let count = trackedLogs.count
        logs = trackedLogs
            .sorted(by: { $0.recordDate > $1.recordDate })
            .enumerated()
            .map { index, event in
                .init(
                    id: event.id,
                    title: "\(count - index). \(event.localizedListItemTitleV2(cascadeTrackedEntity: event.cascadeEntity))",
                    value: event.localizedListItemValueV2)
            }
        if canUpdateEventsForDay {
            var eventsForDayAcc: [Date: [Color]] = [:]
            trackedLogs.forEach { log in
                let key = log.recordDate.middleOfDay
                let color = log.cascadeEntity?.category.color
                if let key = key, let color = color {
                    if eventsForDayAcc[key] == nil {
                        eventsForDayAcc[key] = [color]
                    } else {
                        var colors: [Color] = (eventsForDayAcc[key] ?? [])
                        colors.append(color)
                        eventsForDayAcc[key] = colors
                    }
                }
            }
            eventsForDay = eventsForDayAcc
        }
    }

    func startListeningDBChanges() {
        dataBaseRepository?.output([]).sink { [weak self] some in
            switch some {
            case .generic(let some):
                switch some {
                case .databaseDidInsertedContentOn: break
                case .databaseDidUpdatedContentOn: break
                case .databaseDidDeletedContentOn: break
                case .databaseDidChangedContentItemOn: break
                case .databaseDidFinishChangeContentItemsOn(let table):
                    if table == "\(CDataTrackedLog.self)" {
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)|\(#function)") { [weak self] in
                            // self?.send(.loadEvents)
                        }
                    }
                }
            }
        }.store(in: cancelBag)
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    EventsCalendarViewCoordinator(haveNavigationStack: false)
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
