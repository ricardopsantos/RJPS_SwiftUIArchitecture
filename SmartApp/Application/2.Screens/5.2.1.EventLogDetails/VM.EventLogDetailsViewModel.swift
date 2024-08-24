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
import DesignSystem

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
        case userDidChangedAutoPresentLog(value: Bool)
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
    @Published var userMessage: (text: String, color: ColorSemantic) = ("", .clear)
    @Published var note: String = ""
    @Published var autoPresentLog: Bool = false
    
    // MARK: - Auxiliar Attributes
    private let cancelBag = CancelBag()
    private let dataBaseRepository: DataBaseRepositoryProtocol?
    private let onRouteBack: () -> Void
    public init(dependencies: Dependencies) {
        self.dataBaseRepository = dependencies.dataBaseRepository
        self.trackedLog = dependencies.model.trackedLog
        self.onRouteBack = dependencies.onRouteBack
        super.init()
        self.startListeningDBChanges()
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
            userMessage = ("", .clear)
            Task { [weak self] in
                guard let self = self, var trackedLog = trackedLog else { return }
                trackedLog.note = value
                dataBaseRepository?.trackedLogInsertOrUpdate(
                    trackedLog: trackedLog,
                    trackedEntityId: trackedLog.cascadeEntity?.id ?? "")
            }
        case .userDidChangedAutoPresentLog(value: let value):
            Task { [weak self] in
                guard let self = self, let trackedEntityId = trackedLog?.cascadeEntity?.id else { return }
                if var trackedEntity = dataBaseRepository?.trackedEntityGet(trackedEntityId: trackedEntityId, cascade: false) {
                    trackedEntity.autoPresentLog = value
                    dataBaseRepository?.trackedEntityUpdate(trackedEntity: trackedEntity)
                }
            }
        case .delete(confirmed: let confirmed):
            if !confirmed {
                confirmationSheetType = .delete
            } else {
                Task { [weak self] in
                    guard let self = self, let trackedLog = trackedLog else { return }
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
    func updateUI(event model: Model.TrackedLog) {
        trackedLog = model
        note = model.note
        autoPresentLog = model.cascadeEntity?.autoPresentLog ?? false
    }
    
    func startListeningDBChanges() {
        dataBaseRepository?.output([]).sink { [weak self] some in
            switch some {
            case .generic(let some):
                switch some {
                case .databaseDidInsertedContentOn: break
                case .databaseDidUpdatedContentOn(let table, let id):
                    // Data changed. Reload!
                    if table == "\(CDataTrackedLog.self)", id == self?.trackedLog?.id {
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)\(#function)") { [weak self] in
                            self?.send(.reload)
                            self?.userMessage = ("Updated\n\(Date().timeStyleMedium)".localizedMissing, ColorSemantic.allCool)
                        }
                    }
                case .databaseDidDeletedContentOn(let table, let id):
                    // Record deleted! Route back
                    if table == "\(CDataTrackedLog.self)", id == self?.trackedLog?.id {
                        self?.onRouteBack()
                    }
                case .databaseDidChangedContentItemOn: break
                case .databaseDidFinishChangeContentItemsOn: break
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
    EventLogDetailsViewCoordinator(
        model: .init(trackedLog: .random), haveNavigationStack: false)
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
