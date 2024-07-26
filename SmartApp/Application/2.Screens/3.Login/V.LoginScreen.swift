//
//  AuthenticationScreen.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
import Common
//
import DevTools
import DesignSystem

//
// MARK: - Coordinator
//
struct LoginViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var router = RouterViewModel()
    // MARK: - Usage Attributes

    // MARK: - Body & View
    var body: some View {
        NavigationStack(path: $router.navPath) {
            buildScreen(.login)
                .navigationDestination(for: AppScreen.self, destination: buildScreen)
                .sheet(item: $router.sheetLink, content: buildScreen)
                .fullScreenCover(item: $router.coverLink, content: buildScreen)
        }
        .environmentObject(router)
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .login:
            let dependencies: LoginViewModel.Dependencies = .init(
                model: .init(),
                authenticationViewModel: configuration.authenticationViewModel
            )
            LoginView(dependencies: dependencies)
        default:
            EmptyView().onAppear(perform: {
                DevTools.assert(false, message: "Not predicted \(screen)")
            })
        }
    }
}

struct LoginView: View {
    // MARK: - ViewProtocol

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var router: RouterViewModel
    @StateObject var viewModel: LoginViewModel
    public init(dependencies: LoginViewModel.Dependencies) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
    }

    // MARK: - Usage Attributes
    @State private var password: String = ""
    @State private var email: String = ""

    // MARK: - Body & View
    var body: some View {
        BaseView.with(
            sender: "\(Self.self)",
            appScreen: .login,
            navigationViewEmbed: false,
            scrollViewEmbed: false,
            ignoresSafeArea: false,
            background: .gradient,
            alertModel: viewModel.alertModel
        ) {
            content
        }.onAppear {
            viewModel.send(action: .didAppear)
        }.onDisappear {
            viewModel.send(action: .didDisappear)
        }
    }

    var content: some View {
        VStack(spacing: 0) {
            Header(text: "Welcome".localizedMissing)
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
            emailField
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            passwordField
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
            Spacer()
            TextButton(
                onClick: {
                    AnalyticsManager.shared.handleButtonClickEvent(
                        buttonType: .primary,
                        label: "Login",
                        sender: "\(Self.self)"
                    )
                    viewModel.send(action: .doLogin(email: email, password: password))
                },
                text: "Login".localized,
                enabled: canLogin
            )
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
        }
        .padding(.horizontal, SizeNames.defaultMargin)
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension LoginView {
    var emailField: some View {
        CustomTitleAndCustomTextField(
            label: "Email".localized,
            placeholder: "EmailPlaceHolder".localized,
            isSecured: false,
            inputText: $email
        )
    }

    var passwordField: some View {
        CustomTitleAndCustomTextField(
            label: "Password".localized,
            placeholder: "Password".localized,
            isSecured: false,
            inputText: $password
        )
    }
}

//
// MARK: - Private
//

fileprivate extension LoginView {
    var canLogin: Bool {
        !email.isEmpty && !password.isEmpty
    }
}

#Preview {
    LoginViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        // .environmentObject(AppStateViewModel.defaultForPreviews.authenticationViewModel)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}