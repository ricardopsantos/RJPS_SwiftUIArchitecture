//
//  UserDetailsViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 20/05/2024.
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

public struct EditUserDetailsModel: Equatable, Hashable {
    let counter: Int

    public init(counter: Int = 0) {
        self.counter = counter
    }
}

//
// MARK: - ViewModel (Extensions)
//

public extension EditUserDetailsViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case loadUserInfo
        case saveUser(
            name: String,
            email: String,
            dateOfBirth: Date,
            gender: Gender,
            country: String
        )
    }

    struct Dependencies {
        public let model: EditUserDetailsModel
        public let userRepository: UserRepositoryProtocol
        public let onUserSaved: () -> Void
        public init(model: EditUserDetailsModel, userRepository: UserRepositoryProtocol, onUserSaved: @escaping () -> Void) {
            self.model = model
            self.userRepository = userRepository
            self.onUserSaved = onUserSaved
        }
    }
}

public class EditUserDetailsViewModel2 {
    let xxx: Int
    public init(xxx: Int) {
        self.xxx = xxx
    }
}

@MainActor
public class EditUserDetailsViewModel: ObservableObject {
    // MARK: - View Usage Attributes
    @Published var alertModel: Model.AlertModel?
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var selectedGender: Gender = .male
    @Published var dateOfBirth = Date()
    @Published var selectedCountry: String = ""

    // MARK: - Auxiliar Attributes
    private let cancelBag = CancelBag()
    private let userRepository: UserRepositoryProtocol
    public init(dependencies: Dependencies) {
        self.userRepository = dependencies.userRepository
        dependencies.userRepository.output([])
            .sink { state in
                switch state {
                case .userChanged:
                    dependencies.onUserSaved()
                }
            }.store(in: cancelBag)
    }

    func send(action: Actions) {
        switch action {
        case .didAppear:
            send(action: .loadUserInfo)
        case .didDisappear: ()
        case .saveUser(
            name: let name,
            email: let email,
            dateOfBirth: let dateOfBirth,
            gender: let gender,
            country: let country
        ):
            print("Bug ao nao conseguir mostrar 2 alertas")
            guard email.isValidEmail else {
                alertModel = .init(type: .error, message: "Invalid email".localizedMissing)
                return
            }
            guard !name.isEmpty else {
                alertModel = .init(type: .error, message: "Empty name".localizedMissing)
                return
            }
            userRepository.saveUser(
                name: name,
                email: email,
                dateOfBirth: dateOfBirth,
                gender: gender,
                country: country
            )
        case .loadUserInfo:
            guard let user = userRepository.user else {
                return
            }
            name = user.name ?? ""
            email = user.email
            if let rawValue = user.gender, let gender = Gender(rawValue: rawValue) {
                selectedGender = gender
            }
            dateOfBirth = user.dateOfBirth ?? .now
        }
    }
}

#Preview {
    EditUserDetailsViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
        .environmentObject(AuthenticationViewModel.defaultForPreviews)
}
