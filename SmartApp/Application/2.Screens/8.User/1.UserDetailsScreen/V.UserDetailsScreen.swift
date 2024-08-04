//
//  UserDetailsScreen.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
import Foundation
//
import Domain
import DesignSystem
import Core
import DevTools

//
// MARK: - Coordinator
//
struct UserDetailsViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var router = RouterViewModel()

    // MARK: - Usage Attributes
    let onCompletion: (String) -> Void

    // MARK: - Body & View
    var body: some View {
        NavigationStack(path: $router.navPath) {
            buildScreen(.userDetails)
                .navigationDestination(for: AppScreen.self, destination: buildScreen)
                .sheet(item: $router.sheetLink, content: buildScreen)
                .fullScreenCover(item: $router.coverLink, content: buildScreen)
        }
        .environmentObject(router)
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .userDetails:
            let dependencies: UserDetailsViewModel.Dependencies = .init(
                model: .init(),
                userRepository: configuration.userRepository
            )
            UserDetailsView(dependencies: dependencies, onCompletion: onCompletion)
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

struct UserDetailsView: View {
    // MARK: - ViewProtocol

    @Environment(\.colorScheme) var colorScheme
    //@EnvironmentObject var router: RouterViewModel
    @StateObject var viewModel: UserDetailsViewModel
    let onCompletion: (String) -> Void
    public init(
        dependencies: UserDetailsViewModel.Dependencies,
        onCompletion: @escaping (String) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onCompletion = onCompletion
    }

    // MARK: - Usage Attributes
    @State var name: String = ""
    @State private var selectedGender: Gender = .male
    @State private var dateOfBirth = Date()
    @State private var showingDatePicker = false
    @State var selectedCountry: String = "Other"
    var startDate = Calendar.current.date(
        byAdding: .year,
        value: -35,
        to: Date()
    ) ?? Date()

    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .userDetails,
            navigationViewModel: .disabled,
            background: .default,
            loadingModel: viewModel.loadingModel,
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
        VStack {
            Header(text: "UserDetails".localizedMissing)
            CustomTitleAndCustomTextField(
                label: "Name".localizedMissing,
                placeholder: "NamePlaceHolder".localizedMissing,
                inputText: $name,
                accessibility: .txtName
            )
            .padding(.vertical, SizeNames.defaultMargin)
            GenderPickerView(selected: $selectedGender)
            CustomTitleAndCustomTextField(
                label: "DateOfBirth".localizedMissing,
                placeholder: "DateOfBirthPlaceHolder".localizedMissing,
                inputText: .constant(dateOfBirth.dateStyleShort),
                accessibility: .undefined
            )
            .onTapGesture {
                showingDatePicker = true
            }
            .popover(
                isPresented: $showingDatePicker,
                attachmentAnchor: .point(.bottom),
                arrowEdge: .bottom
            ) {
                DatePickerPopover(
                    title: "DateOfBirthPlaceHolder".localizedMissing,
                    doneButtonLabel: "Done".localizedMissing,
                    isPresented: $showingDatePicker,
                    dateSelection: $dateOfBirth
                )
            }
            .padding(.vertical, SizeNames.defaultMargin)
            CountryPickerView(
                selected: $selectedCountry
            )
            .padding(.vertical, SizeNames.defaultMargin)
            Spacer()
            TextButton(
                onClick: {
                    if hasEnteredAllDetails() {
                        AnalyticsManager.shared.handleButtonClickEvent(
                            buttonType: .primary,
                            label: "Continue",
                            sender: "\(Self.self)"
                        )
                        viewModel.send(action: .save(
                            name: name,
                            dateOfBirth: dateOfBirth,
                            gender: selectedGender,
                            country: selectedCountry
                        ))
                        onCompletion(#function)
                    }
                },
                text: "Continue".localizedMissing,
                accessibility: .fwdButton
            )
        }
        .padding(SizeNames.defaultMargin)
    }

    func hasEnteredAllDetails() -> Bool {
        !name.isEmpty &&
            !selectedGender.rawValue.isEmpty &&
            !dateOfBirth.description.isEmpty &&
            !selectedCountry.isEmpty &&
            !selectedCountry.isEmpty
    }
}

#Preview {
    UserDetailsViewCoordinator(onCompletion: { _ in

    }).environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
