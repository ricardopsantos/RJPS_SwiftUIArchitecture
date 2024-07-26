//
//  SecureAppPreferences.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//
import Combine
//
import Common

public enum SecureAppPreferencesOutputActions: Equatable {
    case deletedAll
    case changedKey(key: SecureAppPreferences.Key)
}

public extension SecureAppPreferences {
    enum Key: String, CaseIterable {
        case authToken
        case password
    }
}

public class SecureAppPreferences {
    public static let shared = SecureAppPreferences()

    private init() {}

    fileprivate var output = PassthroughSubject<SecureAppPreferencesOutputActions, Never>()

    private var keychain: Keychain { Keychain(service: Bundle.main.bundleIdentifier ?? "SmartApp") }
    private func forKey(_ key: SecureAppPreferences.Key) -> String {
        "\(SecureAppPreferences.self).\(key.rawValue)"
    }

    @discardableResult
    private func set(_ value: String?, for key: SecureAppPreferences.Key) -> Bool {
        let k = forKey(key)
        keychain[k] = value
        output.send(.changedKey(key: key))
        return get(for: key) == value
    }

    private func get(for key: SecureAppPreferences.Key) -> String? {
        let k = forKey(key)
        if let value = keychain[k] {
            return value
        }
        return nil
    }
}

extension SecureAppPreferences: SecureAppPreferencesProtocol {
    
    public func output(_ filter: [SecureAppPreferencesOutputActions] = []) -> AnyPublisher<SecureAppPreferencesOutputActions, Never> {
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
    
    public var authToken: String {
        get {  get(for: .authToken) ?? "" }
        set { set(newValue, for: .authToken) }
    }

    public var password: String {
        get { get(for: .password) ?? "" }
        set { set(newValue, for: .password) }
    }

    public func deleteAll() {
        Key.allCases.forEach { key in
            set(nil, for: key)
        }
        output.send(.deletedAll)
    }
}
