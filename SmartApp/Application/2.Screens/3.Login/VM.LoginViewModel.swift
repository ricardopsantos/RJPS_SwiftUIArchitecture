//
//  LoginViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 20/05/2024.
//

import Foundation
import Combine
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
    // MARK: - Usage Attributes
    @Published var alertModel: Model.AlertModel?
    @Published var errorMessage: String = ""
    @Published var password: String = ""
    @Published var email: String = ""
    @Published var canLogin: Bool = false

    // MARK: - Auxiliar Attributes
    private let authenticationViewModel: AuthenticationViewModel
    private var cancelBag = CancelBag()
    public let formEvalDebounce: Double = 0.8
    public init(dependencies: Dependencies) {
        self.authenticationViewModel = dependencies.authenticationViewModel
        isEmailValid
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { valid in valid ? "" : "Invalid email" }
            .assign(to: \.errorMessage, on: self)
            .store(in: cancelBag)
        isFormValid
            .receive(on: RunLoop.main)
            .assign(to: \.canLogin, on: self)
            .store(in: cancelBag)
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

//
// MARK: - Auxiliar
//

fileprivate extension LoginViewModel {
    var isFormValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isPasswordValid, isEmailValid)
            .map { $0 && $1 }
            .eraseToAnyPublisher()
    }

    var isPasswordValid: AnyPublisher<Bool, Never> {
        $password
            .debounce(
                for: RunLoop.SchedulerTimeType.Stride(formEvalDebounce),

                scheduler: RunLoop.main
            )
            .removeDuplicates()
            .map { $0.count >= 3 }
            .eraseToAnyPublisher()
    }

    var isEmailValid: AnyPublisher<Bool, Never> {
        $email
            .debounce(
                for: RunLoop.SchedulerTimeType.Stride(formEvalDebounce),
                scheduler: RunLoop.main
            )
            .removeDuplicates()
            .map(\.isValidEmail)
            .eraseToAnyPublisher()
    }
}

#Preview {
    LoginViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        // .environmentObject(AppStateViewModel.defaultForPreviews.authenticationViewModel)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
