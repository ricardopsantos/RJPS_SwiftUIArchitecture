//
//  FavoriteEventsViewModel.swift
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

public struct FavoriteEventsModel: Equatable, Hashable, Sendable {
    let favorits: [Model.TrackedEntity]
    init(favorits: [Model.TrackedEntity] = []) {
        self.favorits = favorits
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension FavoriteEventsViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case addNewEvent(trackedEntityId: String)
        case loadFavorits
    }

    struct Dependencies {
        let model: FavoriteEventsModel
        let onCompletion: (String) -> Void
        let onNewLog: (Model.TrackedLog) -> Void
        let dataBaseRepository: DataBaseRepositoryProtocol
    }
}

//
// MARK: - ViewModel
//
class FavoriteEventsViewModel: BaseViewModel {
    // MARK: - Usage Attributes
    @Published private(set) var favorits: [Model.TrackedEntity] = []

    // MARK: - Auxiliar Attributes
    private let cancelBag = CancelBag()
    private let dataBaseRepository: DataBaseRepositoryProtocol?
    public init(dependencies: Dependencies) {
        self.dataBaseRepository = dependencies.dataBaseRepository
        self.favorits = dependencies.model.favorits
        super.init()
        dependencies.dataBaseRepository.output([]).sink { [weak self] some in
            switch some {
            case .generic(let some):
                switch some {
                case .databaseDidInsertedContentOn(let table, let id):
                    // New record added
                    if table == "\(CDataTrackedLog.self)" {
                        if let trackedEntity = self?.dataBaseRepository?.trackedLogGet(trackedLogId: id, cascade: true) {
                            Common_Utils.delay(Common.Constants.defaultAnimationsTime * 2) {
                                // Small delay so that the UI counter animation is viewed
                                dependencies.onNewLog(trackedEntity)
                            }
                        }
                    }
                case .databaseDidUpdatedContentOn: break
                case .databaseDidDeletedContentOn(let table, let id):
                    if table == "\(CDataTrackedLog.self)" {
                        // Record deleted
                        Common.ExecutionControlManager.debounce(operationId: #function) {
                            self?.send(.loadFavorits)
                        }
                    }
                case .databaseDidChangedContentItemOn: break
                case .databaseDidFinishChangeContentItemsOn(let table):
                    if table == "\(CDataTrackedLog.self)" {
                        // Record updated
                        Common.ExecutionControlManager.debounce(operationId: #function) {
                            self?.send(.loadFavorits)
                        }
                    }
                }
            }
        }.store(in: cancelBag)
    }

    func send(_ action: Actions) {
        switch action {
        case .didAppear:
            send(.loadFavorits)
        case .didDisappear: ()
        case .loadFavorits:
            Task { [weak self] in
                guard let self = self else { return }
                if let records = dataBaseRepository?.trackedEntityGetAll(
                    favorite: true,
                    archived: false,
                    cascade: true) {
                    favorits = Array(records.prefix(3)) // Display only 3
                }
            }
        case .addNewEvent(trackedEntityId: let trackedEntityId):
            Task { [weak self] in
                guard let self = self else { return }
                var trackedEntityId = trackedEntityId
                if trackedEntityId.isEmpty {
                    trackedEntityId = favorits.first?.id.description ?? ""
                }
                let event: Model.TrackedLog = .init(latitude: 0, longitude: 0, note: "")
                dataBaseRepository?.trackedLogInsertOrUpdate(trackedLog: event, trackedEntityId: trackedEntityId)
            }
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension FavoriteEventsViewModel {}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    FavoriteEventsViewCoordinator(haveNavigationStack: true)
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
