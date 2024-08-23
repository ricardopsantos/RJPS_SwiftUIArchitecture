//
//  EventDetailsViewModel.swift
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

public struct EventDetailsModel: Equatable, Hashable, Sendable {
    let event: Model.TrackedEntity
    init(event: Model.TrackedEntity) {
        self.event = event
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension EventDetailsViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case reload
        case userDidChangedSoundEffect(value: SoundEffect)
        case userDidChangedEventCategory(value: HitHappensEventCategory)
        case userDidChangedLocationRelevant(value: Bool)
        case userDidChangedFavorite(value: Bool)
        case userDidChangedName(value: String)
        case userDidChangedInfo(value: String)
        case deleteTrackedEntity
    }

    struct Dependencies {
        let model: EventDetailsModel
        let onCompletion: (String) -> Void
        let onRouteBack: () -> Void
        let dataBaseRepository: DataBaseRepositoryProtocol
    }
}

//
// MARK: - ViewModel
//
class EventDetailsViewModel: BaseViewModel {
    // MARK: - Usage Attributes
    @Published private(set) var event: Model.TrackedEntity?
    @Published var soundEffect: String = SoundEffect.none.name

    // MARK: - Auxiliar Attributes
    private let cancelBag = CancelBag()
    private let dataBaseRepository: DataBaseRepositoryProtocol?
    private let onRouteBack: () -> Void
    public init(dependencies: Dependencies) {
        self.dataBaseRepository = dependencies.dataBaseRepository
        self.event = dependencies.model.event
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
                    if table == "\(CDataTrackedEntity.self)", id == self?.event?.id {
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
            send(.reload)
        case .didDisappear: ()
        case .reload:
            guard let unwrapped = event else {
                return
            }
            Task { [weak self] in
                guard let self = self else { return }
                if let record = dataBaseRepository?.trackedEntityGet(
                    trackedEntityId: unwrapped.id, cascade: true) {
                    event = record
                    soundEffect = record.sound.name
                }
            }

        case .userDidChangedSoundEffect(value: let value):
            value.play()
            Task { [weak self] in
                guard let self = self, var trackedEntity = event else { return }
                trackedEntity.sound = value
                dataBaseRepository?.trackedEntityUpdate(
                    trackedEntity: trackedEntity)
            }
        case .userDidChangedEventCategory(value: let value):
            Task { [weak self] in
                guard let self = self, var trackedEntity = event else { return }
                trackedEntity.category = value
                dataBaseRepository?.trackedEntityUpdate(
                    trackedEntity: trackedEntity)
            }
        case .userDidChangedLocationRelevant(value: let value):
            Task { [weak self] in
                guard let self = self, var trackedEntity = event else { return }
                trackedEntity.locationRelevant = value
                dataBaseRepository?.trackedEntityUpdate(
                    trackedEntity: trackedEntity)
            }
        case .userDidChangedName(value: let value):
            Task { [weak self] in
                guard let self = self, var trackedEntity = event else { return }
                trackedEntity.name = value
                dataBaseRepository?.trackedEntityUpdate(
                    trackedEntity: trackedEntity)
            }
        case .userDidChangedFavorite(value: let value):
            Task { [weak self] in
                guard let self = self, var trackedEntity = event else { return }
                trackedEntity.favorite = value
                dataBaseRepository?.trackedEntityUpdate(
                    trackedEntity: trackedEntity)
            }
        case .userDidChangedInfo(value: let value):
            Task { [weak self] in
                guard let self = self, var trackedEntity = event else { return }
                trackedEntity.info = value
                dataBaseRepository?.trackedEntityUpdate(
                    trackedEntity: trackedEntity)
            }
        case .deleteTrackedEntity:
            Task { [weak self] in
                guard let self = self, var trackedEntity = event else { return }
                dataBaseRepository?.trackedEntityDelete(trackedEntity: trackedEntity)
            }

        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension EventDetailsViewModel {}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    EventDetailsViewCoordinator(
        model: .init(event: .random(cascadeEvents: [.random])))
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
