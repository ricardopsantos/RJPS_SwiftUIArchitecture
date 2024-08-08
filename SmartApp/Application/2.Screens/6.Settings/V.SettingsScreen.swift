//
//  SettingsView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 03/01/24.
//

import SwiftUI
import Foundation
//
import DevTools
import Common
import DesignSystem

//
// MARK: - Coordinator
//
struct SettingsViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage Attributes

    // MARK: - Body & View
    var body: some View {
        NavigationStack(path: $coordinator.navPath) {
            buildScreen(.settings)
                .navigationDestination(for: AppScreen.self, destination: buildScreen)
                .sheet(item: $coordinator.sheetLink, content: buildScreen)
                .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
        }
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .settings:
            let dependencies: SettingsViewModel.Dependencies = .init(
                model: .init(), onShouldDisplayEditUserDetails: {
                    coordinator.coverLink = .editUserDetails
                },
                authenticationViewModel: configuration.authenticationViewModel,
                nonSecureAppPreferences: configuration.nonSecureAppPreferences,
                userRepository: configuration.userRepository
            )
            SettingsScreen(dependencies: dependencies)
        case .editUserDetails:
            EditUserDetailsViewCoordinator()
        default:
            EmptyView().onAppear(perform: {
                DevTools.assert(false, message: "Not predicted \(screen)")
            })
        }
    }
}

//
// MARK: - View
//

struct SettingsScreen: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: SettingsViewModel
    public init(dependencies: SettingsViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onShouldDisplayEditUserDetails = dependencies.onShouldDisplayEditUserDetails
    }

    // MARK: - Usage Attributes
    @Environment(\.dismiss) var dismiss
    @State private var selectedMode: Common.InterfaceStyle? = InterfaceStyleManager.current
    // @StateObject var networkMonitorViewModel: Common.NetworkMonitorViewModel = .shared

    // MARK: - Auxiliar Attributes
    private let onShouldDisplayEditUserDetails: () -> Void

    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .settings,
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
        ZStack {
            VStack(spacing: SizeNames.defaultMargin) {
                Header(text: "Settings".localizedMissing)
                userDetailsView
                updateButtonView
                AppearancePickerView(selected: $selectedMode)
                bottomButtons
            }.padding(SizeNames.defaultMargin)
            if viewModel.confirmationSheetType != nil {
                confirmationSheet
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension SettingsScreen {
    var userDetailsView: some View {
        VStack(spacing: SizeNames.defaultMargin) {
            TitleAndValueView(title: "Name".localizedMissing, value: viewModel.userName)
            TitleAndValueView(title: "Email".localizedMissing, value: viewModel.userEmail)
            TitleAndValueView(title: "Gender".localizedMissing, value: viewModel.gender.localized)
            TitleAndValueView(title: "DateOfBirth".localizedMissing, value: viewModel.dateOfBirth.dateStyleShort)
            TitleAndValueView(title: "Country".localizedMissing, value: viewModel.country.localized)
        }
    }

    var updateButtonView: some View {
        TextButton(
            onClick: {
                AnalyticsManager.shared.handleButtonClickEvent(
                    buttonType: .primary,
                    label: "Update",
                    sender: "\(Self.self)"
                )
                onShouldDisplayEditUserDetails()
            },
            text: "Update".localizedMissing,

            accessibility: .saveButton
        )
    }

    var bottomButtons: some View {
        VStack {
            Spacer()
            HStack {
                TextButton(
                    onClick: {
                        AnalyticsManager.shared.handleButtonClickEvent(
                            buttonType: .secondary,
                            label: "Logout",
                            sender: "\(Self.self)"
                        )
                        viewModel.confirmationSheetType = .logout
                    },
                    text: "Logout".localizedMissing,
                    style: .secondary,
                    accessibility: .logoutButton
                )
                SwiftUIUtils.FixedHorizontalSpacer(width: SizeNames.defaultMarginSmall)
                TextButton(
                    onClick: {
                        AnalyticsManager.shared.handleButtonClickEvent(
                            buttonType: .secondary,
                            label: "DeleteAccount",
                            sender: "\(Self.self)"
                        )
                        viewModel.confirmationSheetType = .delete
                    },
                    text: "DeleteAccount".localizedMissing,
                    style: .secondary,
                    background: .dangerColor,
                    accessibility: .deleteButton
                )
            }
        }
    }

    var confirmationSheet: some View {
        @State var isOpen = Binding<Bool>(
            get: { viewModel.confirmationSheetType != nil },
            set: { if !$0 { viewModel.confirmationSheetType = nil } }
        )
        return ConfirmationSheetV2(
            isOpen: isOpen,
            title: viewModel.confirmationSheetType!.title,
            subTitle: viewModel.confirmationSheetType!.subTitle,
            confirmationAction: {
                guard let sheetType = viewModel.confirmationSheetType else {
                    return
                }
                switch sheetType {
                case .logout:
                    viewModel.send(action: .performLogout)
                case .delete:
                    viewModel.send(action: .deleteAccount)
                }
            }
        )
    }
}

//
// MARK: - Private
//
fileprivate extension SettingsScreen {}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    SettingsViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
