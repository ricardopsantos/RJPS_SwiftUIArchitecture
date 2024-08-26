//
//  RootView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Common
import DevTools

//
// MARK: - Coordinator
//
struct RootViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage/Auxiliar Attributes

    // MARK: - Body & View
    var body: some View {
        buildScreen(.root)
            .sheet(item: $coordinator.sheetLink, content: buildScreen)
            .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
            .environmentObject(configuration.authenticationViewModel)
    }

    /// Navigation Links
    @ViewBuilder func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .root:
            let nonSecureAppPreferences = configuration.nonSecureAppPreferences
            RootView(dependencies: .init(
                model: .init(
                    isAppStartCompleted: false,
                    isTermsAndConditionsAccepted: nonSecureAppPreferences.isPrivacyPolicyAccepted,
                    isOnboardingCompleted: nonSecureAppPreferences.isOnboardingCompleted
                ),
                nonSecureAppPreferences: configuration.nonSecureAppPreferences
            ))
        default:
            EmptyView().opacity(0).onAppear(perform: {
                DevTools.assert(false, message: "Not predicted \(screen)")
            })
        }
    }
}

//
// MARK: - View
//
struct RootView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: RootViewModel
    public init(dependencies: RootViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
    }

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @State private var root: AppScreen = .splash {
        didSet {
            DevTools.Log.debug(
                .valueChanged(
                    "\(Self.self)",
                    "root",
                    "\(root)"
                ),
                .business
            )
        }
    }

    // MARK: - Body & View
    var body: some View {
        content
    }

    @ViewBuilder
    var content: some View {
        if Common_Utils.onSimulator {
            // swiftlint:disable redundant_discardable_let
            let _ = Self._printChanges()
            // swiftlint:enable redundant_discardable_let
        }
        buildScreen(root)
            .onChange(of: viewModel.isAppStartCompleted) { _ in updateRoot() }
            .onChange(of: viewModel.preferencesChanged) { _ in updateRoot() }
            .onChange(of: viewModel.isTermsAndConditionsAccepted) { _ in updateRoot() }
            .onChange(of: viewModel.isOnboardingCompleted) { _ in updateRoot() }
            .onChange(of: authenticationViewModel.isAuthenticated) { _ in updateRoot() }
    }

    /// Navigation Links
    @ViewBuilder private func buildScreen(_ appScreen: AppScreen) -> some View {
        switch appScreen {
        case .splash:
            SplashViewCoordinator(onCompletion: {
                viewModel.send(action: .start)
            })
        case .mainApp:
            MainTabViewCoordinator()
        case .login:
            LoginViewCoordinator()
        case .termsAndConditions:
            TermsAndConditionsScreen(onCompletion: { _ in viewModel.send(action: .termsAndConditionsAccepted) })
        case .onboarding:
            OnboardingScreen(
                onCompletion: { _ in viewModel.send(action: .onboardingCompleted) },
                onBackPressed: {
                    viewModel.send(action: .termsAndConditionsNotAccepted)
                }
            )
        default:
            Text("Not predicted \(root)")
        }
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension RootView {}

//
// MARK: - Private
//
fileprivate extension RootView {
    func updateRoot() {
        switch selectedApp() {
        case .hitHappens:
            root = .mainApp
        case .template:
            if !viewModel.isAppStartCompleted {
                root = .splash
            } else if !authenticationViewModel.isAuthenticated {
                root = .login
            } else if authenticationViewModel.isAuthenticated {
                if !viewModel.isTermsAndConditionsAccepted {
                    root = .termsAndConditions
                } else if !viewModel.isOnboardingCompleted {
                    root = .onboarding
                } else {
                    root = .mainApp
                }
            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    RootViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
