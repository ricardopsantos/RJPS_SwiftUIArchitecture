//
//  SettingsViewModel.swift
//  SmartApp
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

struct SettingsModel {
    let some: Bool
    init(some: Bool = false) {
        self.some = some
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension SettingsViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case loadUserInfo
        case handleConfirmation
        case performLogout
        case deleteAccount
    }

    struct Dependencies {
        let model: SettingsModel
        let authenticationViewModel: AuthenticationViewModel
        let nonSecureAppPreferences: NonSecureAppPreferencesProtocol
        let userRepository: UserRepositoryProtocol
    }
}

@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - View Usage Attributes
    @Published private(set) var alertModel: Model.AlertModel?
    @Published private(set) var userName: String = ""
    @Published private(set) var userEmail: String = ""
    @Published private(set) var gender: String = ""
    @Published private(set) var dateOfBirth: Date = .now
    @Published private(set) var country = ""
    @Published var confirmationSheetType: ConfirmationSheet?
    @Published var isConfirmationGiven = false {
        didSet {
            if isConfirmationGiven {
                send(action: .handleConfirmation)
                confirmationSheetType = nil
            }
        }
    }

    // MARK: - Auxiliar Attributes
    private var cancelBag = CancelBag()
    private let authenticationViewModel: AuthenticationViewModel?
    private let nonSecureAppPreferences: NonSecureAppPreferencesProtocol?
    private let userRepository: UserRepositoryProtocol?
    public init(dependencies: Dependencies) {
        self.authenticationViewModel = dependencies.authenticationViewModel
        self.nonSecureAppPreferences = dependencies.nonSecureAppPreferences
        self.userRepository = dependencies.userRepository
        dependencies.userRepository.output([])
            .sink { [weak self] state in
                switch state {
                case .userChanged:
                    self?.send(action: .loadUserInfo)
                }
            }.store(in: cancelBag)
    }

    func send(action: Actions) {
        switch action {
        case .didAppear:
            send(action: .loadUserInfo)
        case .didDisappear: ()
        case .loadUserInfo:
            guard let user = userRepository?.user else {
                return
            }
            userName = user.name ?? ""
            userEmail = user.email
            gender = user.gender ?? Gender.male.rawValue
            dateOfBirth = user.dateOfBirth ?? .now
            country = user.country ?? ""
        case .performLogout:
            Task { @MainActor in
                do {
                    try await authenticationViewModel?.logout()
                } catch {
                    let errorMessage = "Error while logging out."
                    alertModel = .init(type: .error, message: errorMessage)
                    ErrorsManager.handleError(message: "\(Self.self).\(action)", error: error)
                }
            }
        case .deleteAccount:
            Task { @MainActor in
                do {
                    try await authenticationViewModel?.deleteAccount()
                } catch {
                    let errorMessage = "Error while deleting account."
                    alertModel = .init(type: .error, message: errorMessage)
                    ErrorsManager.handleError(message: "\(Self.self).\(action)", error: error)
                }
            }
        case .handleConfirmation:
            switch confirmationSheetType {
            case .logout:
                send(action: .performLogout)
            case .delete:
                send(action: .deleteAccount)
            case nil:
                let errorMessage = "No bottom sheet found"
                alertModel = .init(type: .error, message: errorMessage)
                ErrorsManager.handleError(message: "\(Self.self).\(action)", error: nil)
            }
        }
    }
}

extension SettingsViewModel {
    enum ConfirmationSheet {
        case logout
        case delete

        var title: String {
            switch self {
            case .logout:
                "LogoutBottomSheetTitle".localizedMissing
            case .delete:
                "DeleteAccountBottomSheetTitle".localizedMissing
            }
        }

        var subTitle: String {
            switch self {
            case .logout:
                "LogoutBottomSheetSubTitle".localizedMissing
            case .delete:
                "DeleteAccountBottomSheetSubTitle".localizedMissing
            }
        }
    }
}

#Preview {
    SettingsViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
