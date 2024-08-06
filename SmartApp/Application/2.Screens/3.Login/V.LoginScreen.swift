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
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage Attributes

    // MARK: - Body & View
    var body: some View {
        NavigationStack(path: $coordinator.navPath) {
            buildScreen(.login)
                .navigationDestination(for: AppScreen.self, destination: buildScreen)
                .sheet(item: $coordinator.sheetLink, content: buildScreen)
                .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
        }
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

struct LoginView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    // @EnvironmentObject var router: RouterViewModel
    @StateObject var viewModel: LoginViewModel
    public init(dependencies: LoginViewModel.Dependencies) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
    }

    // MARK: - Usage Attributes
    // @State private var password: String = ""

    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .login,
            navigationViewModel: .disabled,
            background: .default,
            loadingModel: viewModel.loadingModel,
            alertModel: viewModel.alertModel,
            networkStatus: nil
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
            messageView
            Spacer()
            loginButton
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
        }
        .padding(.horizontal, SizeNames.defaultMargin)
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension LoginView {
    var loginButton: some View {
        TextButton(
            onClick: {
                AnalyticsManager.shared.handleButtonClickEvent(
                    buttonType: .primary,
                    label: "Login",
                    sender: "\(Self.self)"
                )
                viewModel.send(action: .doLogin(
                    email: viewModel.email,
                    password: viewModel.password
                ))
            },
            text: "Login".localized,
            enabled: viewModel.canLogin,
            accessibility: .loginButton
        )
    }

    var messageView: some View {
        Group {
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .fontSemantic(.callout)
                    .foregroundColorSemantic(.danger)
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
            } else {
                EmptyView()
            }
        }
    }

    var emailField: some View {
        CustomTitleAndCustomTextField(
            label: "Email".localized,
            placeholder: "EmailPlaceHolder".localized,
            inputText: $viewModel.email,
            isSecured: false,
            accessibility: .txtEmail
        )
    }

    var passwordField: some View {
        CustomTitleAndCustomTextField(
            label: "Password".localized,
            placeholder: "Password".localized,
            inputText: $viewModel.password,
            isSecured: true,
            accessibility: .txtPassword
        )
    }
}

//
// MARK: - Private
//

fileprivate extension LoginView {}

#Preview {
    LoginViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        // .environmentObject(AppStateViewModel.defaultForPreviews.authenticationViewModel)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
