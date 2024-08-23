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
import DesignSystem

//
// MARK: - Model
//

public struct CascadeEventListItem: Equatable, Hashable, Sendable {
    let id: String
    let title: String
    let value: String
    init(id: String, title: String, value: String) {
        self.title = title
        self.value = value
        self.id = id
    }
}

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

extension EventDetailsViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case reload
        case userDidChangedSoundEffect(value: SoundEffect)
        case userDidChangedEventCategory(value: HitHappensEventCategory)
        case userDidChangedLocationRelevant(value: Bool)
        case userDidChangedFavorite(value: Bool)
        case userDidChangedArchived(value: Bool)
        case userDidChangedName(value: String)
        case userDidChangedInfo(value: String)
        case delete(confirmed: Bool)
        case usedDidTappedLogEvent(trackedLogId: String)
        case handleConfirmation
    }

    struct Dependencies {
        let model: EventDetailsModel
        let onCompletion: (String) -> Void
        let onRouteBack: () -> Void
        let onTrackedLogTapped: (Model.TrackedLog) -> Void
        let dataBaseRepository: DataBaseRepositoryProtocol
    }
}

//
// MARK: - ViewModel
//
class EventDetailsViewModel: BaseViewModel {
    // MARK: - Usage Attributes
    @Published private(set) var event: Model.TrackedEntity?
    @Published private(set) var cascadeEvents: [CascadeEventListItem]?
    @Published var soundEffect: String = SoundEffect.none.name
    @Published var favorite: Bool = false
    @Published var archived: Bool = false
    @Published var name: String = ""
    @Published var info: String = ""
    @Published var userMessage: (text: String, color: ColorSemantic) = ("", .clear)

    // MARK: - Auxiliar Attributes
    private let cancelBag = CancelBag()
    private let dataBaseRepository: DataBaseRepositoryProtocol?
    private let onRouteBack: () -> Void
    private let onTrackedLogTapped: (Model.TrackedLog) -> Void
    @Published var confirmationSheetType: ConfirmationSheet?

    public init(dependencies: Dependencies) {
        self.dataBaseRepository = dependencies.dataBaseRepository
        self.event = dependencies.model.event
        self.onRouteBack = dependencies.onRouteBack
        self.onTrackedLogTapped = dependencies.onTrackedLogTapped
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
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)\(#function)") { [weak self] in
                            self?.send(.reload)
                            self?.userMessage = ("Updated (\(Date().timeStyleMedium))".localizedMissing, ColorSemantic.allCool)
                        }
                    }
                    if table == "\(CDataTrackedLog.self)" {
                        Common.ExecutionControlManager.debounce(operationId: "\(Self.self)\(#function)") { [weak self] in
                            self?.send(.reload)
                        }
                    }
                }
            }
        }.store(in: cancelBag)
    }

    func send(_ action: Actions) {
        switch action {
        case .didAppear:
            guard let unwrapped = event else {
                return
            }
            updateUI(event: unwrapped)
        case .didDisappear: ()
        case .reload:
            guard let unwrapped = event else {
                return
            }
            Task { [weak self] in
                guard let self = self else { return }
                if let record = dataBaseRepository?.trackedEntityGet(
                    trackedEntityId: unwrapped.id, cascade: true) {
                    updateUI(event: record)
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
        case .userDidChangedArchived(value: let value):
            Task { [weak self] in
                guard let self = self, var trackedEntity = event else { return }
                trackedEntity.archived = value
                if value {
                    // archived cant be favorite
                    trackedEntity.favorite = false
                }
                dataBaseRepository?.trackedEntityUpdate(
                    trackedEntity: trackedEntity)
            }
        case .userDidChangedFavorite(value: let value):
            Task { [weak self] in
                guard let self = self, var trackedEntity = event else { return }
                trackedEntity.favorite = value
                if value {
                    // archived cant be favorite
                    trackedEntity.archived = false
                }
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
        case .delete(confirmed: let confirmed):
            if !confirmed {
                confirmationSheetType = .delete
            } else {
                Task { [weak self] in
                    guard let self = self, let trackedEntity = event else { return }
                    dataBaseRepository?.trackedEntityDelete(trackedEntity: trackedEntity)
                }
            }
        case .usedDidTappedLogEvent(trackedLogId: let trackedLogId):
            Task { [weak self] in
                guard let self = self else { return }
                if let rackedLog = dataBaseRepository?.trackedLogGet(trackedLogId: trackedLogId, cascade: true) {
                    onTrackedLogTapped(rackedLog)
                }
            }
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension EventDetailsViewModel {
    // @MainActor
    func updateUI(event model: Model.TrackedEntity) {
        event = model
        cascadeEvents = model.cascadeEvents?.map {
            .init(
                id: $0.id,
                title: $0.localizedListItemTitle,
                value: $0.localizedListItemValue) }
        soundEffect = model.sound.name
        favorite = model.favorite
        archived = model.archived
        name = model.name
        info = model.info
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    EventDetailsViewCoordinator(
        model: .init(event: .random(cascadeEvents: [.random])), haveNavigationStack: false)
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
