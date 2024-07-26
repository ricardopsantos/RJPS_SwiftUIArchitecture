//
//  UserRepository.swift
//  SmartApp
//
//  Created by Ricardo Santos on 16/05/2024.
//

import Foundation
import Combine
//
import Common
import DevTools

public enum UserRepositoryOutputActions: Equatable {
    case userChanged
}

public class UserRepository {
    fileprivate let secureAppPreferences: SecureAppPreferencesProtocol
    fileprivate let nonSecureAppPreferences: NonSecureAppPreferencesProtocol
    public init(
        secureAppPreferences: SecureAppPreferencesProtocol,
        nonSecureAppPreferences: NonSecureAppPreferencesProtocol
    ) {
        self.secureAppPreferences = secureAppPreferences
        self.nonSecureAppPreferences = nonSecureAppPreferences
    }

    fileprivate var output = PassthroughSubject<UserRepositoryOutputActions, Never>()
}

extension UserRepository: UserRepositoryProtocol {
    public func output(_ filter: [UserRepositoryOutputActions] = []) -> AnyPublisher<UserRepositoryOutputActions, Never> {
        if filter.isEmpty {
            return output.eraseToAnyPublisher()
        } else {
            return output
                  .filter { action in
                      filter.contains { $0 == action }
                  }
                  .eraseToAnyPublisher()
        }
    }

    public var user: Model.User? {
        let key = NonSecureAppPreferences.Key.user
        guard let savedUser = nonSecureAppPreferences.nonSecureUserDefaults.data(forKey: key.rawValue) else { return nil }
        let decoder = JSONDecoder()
        do {
            var result = try decoder.decode(Model.User.self, from: savedUser)
            result.password = result.password.decrypted
            return result
        } catch {
            DevTools.assert(false, message: "Failed to decode user: \(error)")
            return nil
        }
    }

    public func saveUser(
        name: String,
        email: String,
        dateOfBirth: Date,
        gender: Gender,
        country: String
    ) {
        let password = secureAppPreferences.password.encrypted ?? ""
        let user = Model.User(
            name: name,
            email: email,
            password: password,
            dateOfBirth: dateOfBirth,
            gender: gender.rawValue,
            country: country
        )
        saveUser(user: user)
    }

    public func saveUser(user: Model.User) {
        let key = NonSecureAppPreferences.Key.user
        var user = user
        if let dateOfBirth = user.dateOfBirth {
            user.dateOfBirth = dateOfBirth.beginningOfDay
        }
        if user.password.isEmpty {
            user.password = secureAppPreferences.password.encrypted ?? ""
        }
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(user)
            nonSecureAppPreferences.nonSecureUserDefaults.set(encoded, forKey: key.rawValue)
            output.send(.userChanged)
        } catch {
            DevTools.assert(false, message: "Failed to encode user: \(error)")
        }
    }
}
