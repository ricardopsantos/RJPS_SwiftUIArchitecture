//
//  EventLogDetailsViewModel.swift
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

public struct EventLogDetailsModel: Equatable, Hashable, Sendable {
    let trackedLog: Model.TrackedLog
    init(trackedLog: Model.TrackedLog) {
        self.trackedLog = trackedLog
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension EventLogDetailsViewModel {
    enum ConfirmationSheet {
        case delete

        var title: String {
            switch self {
            case .delete:
                "DeleteTitle".localizedMissing
            }
        }

        var subTitle: String {
            switch self {
            case .delete:
                "DeleteSubTitle".localizedMissing
            }
        }
    }
}

extension EventLogDetailsViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case reload
        case userDidChangedNote(value: String)
        case delete(confirmed: Bool)
        case handleConfirmation
    }

    struct Dependencies {
        let model: EventLogDetailsModel
        let onCompletion: (String) -> Void
        let onRouteBack: () -> Void
        let dataBaseRepository: DataBaseRepositoryProtocol
    }
}

//
// MARK: - ViewModel
//
class EventLogDetailsViewModel: BaseViewModel {
    // MARK: - Usage Attributes
    @Published private(set) var trackedLog: Model.TrackedLog?
    @Published var confirmationSheetType: ConfirmationSheet?

    // MARK: - Auxiliar Attributes
    private let cancelBag = CancelBag()
    private let dataBaseRepository: DataBaseRepositoryProtocol?
    private let onRouteBack: () -> Void
    public init(dependencies: Dependencies) {
        self.dataBaseRepository = dependencies.dataBaseRepository
        self.trackedLog = dependencies.model.trackedLog
        self.onRouteBack = dependencies.onRouteBack
        super.init()
        dependencies.dataBaseRepository.output([]).sink { [weak self] some in
            switch some {
            case .generic(let some):
                switch some {
                case .databaseDidInsertedContentOn: break
                case .databaseDidUpdatedContentOn: break
                case .databaseDidDeletedContentOn(let table, let id):
                    // Record deleted! Route back
                    if table == "\(CDataTrackedLog.self)", id == self?.trackedLog?.id {
                        self?.onRouteBack()
                    }
                case .databaseDidChangedContentItemOn: break
                case .databaseDidFinishChangeContentItemsOn(let table):
                    // Data changed. Reload!
                    if table == "\(CDataTrackedEntity.self)" {
                        self?.send(.reload)
                    }
                }
            }
        }.store(in: cancelBag)
    }

    func send(_ action: Actions) {
        switch action {
        case .didAppear:
            guard let unwrapped = trackedLog else {
                return
            }
            updateUI(event: unwrapped)
        case .didDisappear: ()
        case .reload:
            guard let unwrapped = trackedLog else {
                return
            }
            Task { [weak self] in
                guard let self = self else { return }
                if let record = dataBaseRepository?.trackedEntityGet(
                    trackedEntityId: unwrapped.id, cascade: true) {
                    updateUI(event: unwrapped)
                }
            }

        case .handleConfirmation:
            switch confirmationSheetType {
            case .delete:
                send(.delete(confirmed: true))
            case nil:
                let errorMessage = "No bottom sheet found"
                alertModel = .init(type: .error, message: errorMessage)
                ErrorsManager.handleError(message: "\(Self.self).\(action)", error: nil)
            }

        case .userDidChangedNote(value: let value):
            Task { [weak self] in
                guard let self = self, var trackedLog = trackedLog else { return }
                trackedLog.note = value
                dataBaseRepository?.trackedLogInsertOrUpdate(
                    trackedLog: trackedLog,
                    trackedEntityId: trackedLog.cascadeEntity?.id ?? "")
            }

        case .delete(confirmed: let confirmed):
            if !confirmed {
                confirmationSheetType = .delete
            } else {
                Task { [weak self] in
                    guard let self = self, var trackedLog = trackedLog else { return }
                    dataBaseRepository?.trackedLogDelete(trackedLogId: trackedLog.id)
                }
            }
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension EventLogDetailsViewModel {
    // @MainActor
    func updateUI(event model: Model.TrackedLog) {
        trackedLog = model
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    EventLogDetailsViewCoordinator(
        model: .init(trackedLog: .random), haveNavigationStack: false)
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
