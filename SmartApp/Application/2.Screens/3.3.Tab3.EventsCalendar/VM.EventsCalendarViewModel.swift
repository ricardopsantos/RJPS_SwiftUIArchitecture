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
        case loadEventsForDay(value: Date?)
        case loadEventForMonth(value: Date)
    }

    struct Dependencies {
        let model: EventsCalendarModel
        let onSelected: (Model.TrackedEntity) -> Void
        let dataBaseRepository: DataBaseRepositoryProtocol
    }
}

//
// MARK: - ViewModel
//
class EventsCalendarViewModel: BaseViewModel {
    // MARK: - Usage Attributes
    @Published private(set) var message: String = ""
    @Published private(set) var events: [Model.TrackedEntity] = []
    @Published private(set) var eventsLogs: [Model.TrackedLog] = []
    @Published var selectedDay: Date?
    @Published var selectedMonth: Date = Date()

    // MARK: - Auxiliar Attributes
    private let cancelBag = CancelBag()
    private let dataBaseRepository: DataBaseRepositoryProtocol?
    public init(dependencies: Dependencies) {
        self.dataBaseRepository = dependencies.dataBaseRepository
        self.message = dependencies.model.message
        super.init()
        startListeningDBChanges()
    }

    func send(_ action: Actions) {
        switch action {
        case .didAppear:
            send(.loadEventForMonth(value: selectedMonth))
        case .didDisappear: ()
        case .loadEventsForDay(value: let value):
            guard let value = value else {
                // No day, or un-selected day? Load for month
                send(.loadEventForMonth(value: selectedMonth))
                return
            }
            Task { [weak self] in
                guard let self = self else { return }
                let min = value.beginningOfDay ?? Date()
                let max = value.endOfDay ?? Date()
                if let records = dataBaseRepository?.trackedLogGetAll(min: min, maxDate: max, cascade: true)
                {
                    eventsLogs = records
                    print(records.count)
                }
            }
        case .loadEventForMonth(value: let value):
            Task { [weak self] in
                guard let self = self else { return }
                let min = value.beginningOfMonth ?? Date()
                let max = value.endOfMonth ?? Date()
                if let records = dataBaseRepository?.trackedLogGetAll(min: min, maxDate: max, cascade: true)
                {
                    eventsLogs = records
                    print(records.count)
                }
            }
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension EventsCalendarViewModel {
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
                        Common.ExecutionControlManager.debounce(operationId: #function) { [weak self] in
                            //    self?.send(.loadEvents)
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
