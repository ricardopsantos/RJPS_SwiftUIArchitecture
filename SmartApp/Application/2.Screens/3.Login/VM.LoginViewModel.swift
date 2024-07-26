//
//  LoginViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 20/05/2024.
//

import Foundation
import SwiftUI
//
import Core
import Common

//
// MARK: - Model
//

struct LoginModel {
    let some: Bool
    init(some: Bool = false) {
        self.some = some
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension LoginViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case doLogin(email: String, password: String)
    }

    struct Dependencies {
        let model: SettingsModel
        let authenticationViewModel: AuthenticationViewModel
    }
}

@MainActor
class LoginViewModel: ObservableObject {
    @Published var alertModel: Model.AlertModel?
    private let authenticationViewModel: AuthenticationViewModel
    public init(dependencies: Dependencies) {
        self.authenticationViewModel = dependencies.authenticationViewModel
    }

    func send(action: Actions) {
        switch action {
        case .didAppear: ()
        case .didDisappear: ()
        case .doLogin(email: let email, password: let password):
            var canLogin: Bool {
                !email.isEmpty && !password.isEmpty
            }
            guard canLogin else {
                return
            }
            Task { @MainActor in
                do {
                    let user = Model.User(email: email, password: password)
                    try await authenticationViewModel.login(user: user)
                } catch {
                    alertModel = .tryAgainLatter
                    ErrorsManager.handleError(message: "\(Self.self).\(action)", error: error)
                }
            }
        }
    }
}

#Preview {
    LoginViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        // .environmentObject(AppStateViewModel.defaultForPreviews.authenticationViewModel)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
