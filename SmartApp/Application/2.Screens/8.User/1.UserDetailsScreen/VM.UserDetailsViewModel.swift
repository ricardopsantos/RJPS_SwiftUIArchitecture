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
import Core
import Common

//
// MARK: - Model
//

struct UserDetailsModel: Equatable, Hashable, Sendable {
    let counter: Int

    init(counter: Int = 0) {
        self.counter = counter
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension UserDetailsViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case save(
            name: String,
            dateOfBirth: Date,
            gender: Gender,
            country: String
        )
    }

    struct Dependencies {
        let model: UserDetailsModel
        let userRepository: UserRepositoryProtocol
    }
}

class UserDetailsViewModel: BaseViewModel {
    // MARK: - View Usage Attributes

    // MARK: - Auxiliar Attributes
    private let userRepository: UserRepositoryProtocol?
    public init(dependencies: Dependencies) {
        self.userRepository = dependencies.userRepository
    }

    func send(action: Actions) {
        switch action {
        case .didAppear: ()
        case .didDisappear: ()
        case .save(
            name: let name,
            dateOfBirth: let dateOfBirth,
            gender: let gender,
            country: let country
        ):
            userRepository?.saveUser(user: .init(
                name: name,
                email: name.replace(" ", with: ".") + "@gmail.com",
                password: "",
                dateOfBirth: dateOfBirth,
                gender: gender.rawValue,
                country: country
            ))
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    UserDetailsViewCoordinator(onCompletion: { _ in })
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
