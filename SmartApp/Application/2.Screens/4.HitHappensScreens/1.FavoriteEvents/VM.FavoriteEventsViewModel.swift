//
//  FavoriteEventsViewModel.swift
//  Common
//
//  Created by Ricardo Santos on 03/01/24.
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
                case .databaseDidInsertedContentOn: break
                case .databaseDidUpdatedContentOn: break
                case .databaseDidDeletedContentOn: break
                case .databaseDidChangedContentItemOn: break
                case .databaseDidFinishChangeContentItemsOn(let table):
                    if table == "\(CDataTrackedLog.self)" {
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
                    favorits = records
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
    FavoriteEventsViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
