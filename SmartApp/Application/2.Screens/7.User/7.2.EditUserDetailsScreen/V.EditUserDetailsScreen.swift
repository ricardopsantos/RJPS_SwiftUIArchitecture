//
//  EditUserDetailsScreen.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Common
import Core
import DevTools
import DesignSystem

//
// MARK: - Coordinator
//
struct EditUserDetailsViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var router = RouterViewModel()
    // MARK: - Usage Attributes
    @Environment(\.dismiss) var dismiss

    // MARK: - Body & View
    var body: some View {
        NavigationStack(path: $router.navPath) {
            buildScreen(.editUserDetails)
                .navigationDestination(for: AppScreen.self, destination: buildScreen)
                .sheet(item: $router.sheetLink, content: buildScreen)
                .fullScreenCover(item: $router.coverLink, content: buildScreen)
        }
        .environmentObject(router)
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .editUserDetails:
            let dependencies: EditUserDetailsViewModel.Dependencies = .init(
                model: .init(),
                userRepository: configuration.userRepository, onUserSaved: {
                    dismiss()
                }
            )
            EditUserDetailsView(dependencies: dependencies)
        default:
            EmptyView().onAppear(perform: {
                DevTools.assert(false, message: "Not predicted \(screen)")
            })
        }
    }
}

struct EditUserDetailsView: View {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var router: RouterViewModel
    @StateObject var viewModel: EditUserDetailsViewModel
    public init(dependencies: EditUserDetailsViewModel.Dependencies) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
    }

    // MARK: - Usage Attributes
    @Environment(\.dismiss) var dismiss
    @State private var showConfirmation: Bool = false
    @State private var isConfirmationGiven: Bool = false
    @State private var showingDatePicker: Bool = false
    private var startDate = Calendar.current.date(byAdding: .year, value: -100, to: Date()) ?? Date()

    // MARK: - Body & View
    var body: some View {
        BaseView.with(
            sender: "\(Self.self)",
            appScreen: .editUserDetails,
            navigationViewEmbed: false,
            scrollViewEmbed: false,
            ignoresSafeArea: true,
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
        ZStack {
            VStack {
                Header(
                    text: "UpdateUserDetails".localizedMissing,
                    hasCloseButton: true,
                    onBackOrCloseClick: {
                        AnalyticsManager.shared.handleButtonClickEvent(
                            buttonType: .back,
                            label: "Back",
                            sender: "\(Self.self)"
                        )
                        dismiss()
                    }
                )
                CustomTitleAndCustomTextField(
                    label: "Name".localizedMissing,
                    placeholder: "NamePlaceHolder".localizedMissing,
                    inputText: $viewModel.name
                )
                .padding(.vertical, SizeNames.defaultMargin)

                CustomTitleAndCustomTextField(
                    label: "Email".localizedMissing,
                    placeholder: "EmailPlaceHolder".localizedMissing,
                    inputText: $viewModel.email
                )

                GenderView(selectedGender: $viewModel.selectedGender)
                    .padding(.vertical, SizeNames.defaultMargin)

                CustomTitleAndCustomTextField(
                    label: "DateOfBirth".localizedMissing,
                    placeholder: "DateOfBirthPlaceHolder".localizedMissing,
                    inputText: .constant(viewModel.dateOfBirth.dateStyleShort)
                )
                .onTapGesture {
                    showingDatePicker = true
                }
                .popover(isPresented: $showingDatePicker, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                    DatePickerPopover(
                        isPresented: $showingDatePicker,
                        dateSelection: $viewModel.dateOfBirth,
                        title: "DateOfBirthPlaceHolder".localizedMissing,
                        doneButtonLabel: "Done".localizedMissing
                    )
                }

                CountryView(selectedCountry: $viewModel.selectedCountry)

                Spacer()

                TextButton(onClick: {
                    if hasEnteredAllDetails {
                        let userProperties = [
                            "name": viewModel.name,
                            "email": viewModel.email,
                            "gender": viewModel.selectedGender,
                            "country": viewModel.selectedCountry
                        ] as [String: Any]
                        AnalyticsManager.shared.handleCustomEvent(eventType: .updateUser, properties: userProperties)
                        AnalyticsManager.shared.handleButtonClickEvent(
                            buttonType:
                            .primary,
                            label: "Update",
                            sender: "\(Self.self)"
                        )
                        showConfirmation = true
                    }
                }, text: "Update".localizedMissing)
            }.padding(SizeNames.defaultMargin)

            Spacer()

            if showConfirmation {
                confirmationSheet
            }
        }
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension EditUserDetailsView {
    var confirmationSheet: some View {
        @State var isOpen = Binding<Bool>(
            get: { showConfirmation },
            set: { showConfirmation = $0 }
        )
        return ConfirmationSheetV2(
            isOpen: isOpen,
            title: "SaveUserInfoBottomSheetTitle".localizedMissing,
            subTitle: "SaveUserInfoBottomSheetSubTitle".localizedMissing,
            confirmationAction: {
                viewModel.send(
                    action: .saveUser(
                        name: viewModel.name,
                        email: viewModel.email,
                        dateOfBirth: viewModel.dateOfBirth,
                        gender: viewModel.selectedGender,
                        country: viewModel.selectedCountry
                    )
                )
            }
        )
    }
}

//
// MARK: - Private
//
fileprivate extension EditUserDetailsView {
    var hasEnteredAllDetails: Bool {
        !viewModel.name.isEmpty && !viewModel.selectedGender.rawValue.isEmpty && !viewModel.dateOfBirth.description.isEmpty
    }
}

#Preview {
    EditUserDetailsViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
        .environmentObject(AuthenticationViewModel.defaultForPreviews)
}
