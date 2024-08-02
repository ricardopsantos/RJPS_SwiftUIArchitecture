//
//  RootViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import SwiftUI
//
import Domain
import Common
import Core

struct RootModel: Equatable, Hashable {
    let isAppStartCompleted: Bool
    let isUserDetailsFilled: Bool
    let isTermsAndConditionsAccepted: Bool
    let isOnboardingCompleted: Bool

    init(
        isAppStartCompleted: Bool = false,
        isUserDetailsFilled: Bool = false,
        isTermsAndConditionsAccepted: Bool = false,
        isOnboardingCompleted: Bool = false
    ) {
        self.isAppStartCompleted = isAppStartCompleted
        self.isUserDetailsFilled = isUserDetailsFilled
        self.isTermsAndConditionsAccepted = isTermsAndConditionsAccepted
        self.isOnboardingCompleted = isOnboardingCompleted
    }
}

extension RootViewModel {
    enum Actions {
        case start
        // case markInitialScreenAsVisited
        case markUserDetailsCompleted
        case termsAndConditionsAccepted
        case termsAndConditionsNotAccepted
        case onboardingCompleted
    }

    struct Dependencies {
        let model: RootModel
        let nonSecureAppPreferences: NonSecureAppPreferencesProtocol
    }
}

@MainActor
class RootViewModel: ObservableObject {
    // MARK: - Usage Attributes
    @Published private(set) var alertModel: Model.AlertModel?
    @Published private(set) var isAppStartCompleted: Bool = false
    @Published private(set) var isUserDetailsFilled: Bool = false
    @Published private(set) var isTermsAndConditionsAccepted: Bool = false
    @Published private(set) var isOnboardingCompleted: Bool = false
    @Published private(set) var preferencesChanged: Date = .now
    
    // MARK: - Auxiliar Attributes
    private var cancelBag = CancelBag()
    private var nonSecureAppPreferences: NonSecureAppPreferencesProtocol?
    public init(dependencies: Dependencies) {
        self.nonSecureAppPreferences = dependencies.nonSecureAppPreferences
        self.isAppStartCompleted = dependencies.model.isAppStartCompleted
        self.isUserDetailsFilled = dependencies.model.isUserDetailsFilled
        self.isTermsAndConditionsAccepted = dependencies.model.isTermsAndConditionsAccepted
        self.isOnboardingCompleted = dependencies.model.isOnboardingCompleted
        dependencies.nonSecureAppPreferences.output([]).sinkToReceiveValue { [weak self] _ in
            self?.preferencesChanged = .now
        }.store(in: cancelBag)
    }

    // MARK: - Functions

    func send(action: Actions) {
        switch action {
        case .start:
            guard !isAppStartCompleted else { return }
            // All starting set up will be done here
            // testing load time 2 seconds
            Common_Utils.delay(2) { [weak self] in
                self?.isAppStartCompleted = true
            }
        case .markUserDetailsCompleted:
            guard !isUserDetailsFilled else { return }
            nonSecureAppPreferences?.isProfileComplete = true
            isUserDetailsFilled = true
        case .termsAndConditionsAccepted:
            guard !isTermsAndConditionsAccepted else { return }
            nonSecureAppPreferences?.isPrivacyPolicyAccepted = true
            isTermsAndConditionsAccepted = true
        case .termsAndConditionsNotAccepted:
            guard isTermsAndConditionsAccepted else { return }
            isTermsAndConditionsAccepted = false

        case .onboardingCompleted:
            guard !isOnboardingCompleted else { return }
            nonSecureAppPreferences?.isOnboardingCompleted = true
            isOnboardingCompleted = true
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension RootViewModel {}

#Preview {
    RootViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
