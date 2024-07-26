//
//  NonSecureAppPreferences.swift
//  SmartApp
//
//  Created by Ricardo Santos on 03/01/24.
//

import Foundation
import Combine
//
import DevTools
import Common

public enum NonSecureAppPreferencesOutputActions: Equatable {
    case deletedAll
    case changedKey(key: NonSecureAppPreferences.Key)
}

// MARK: - NonSecureAppPreferences.Keys
public extension NonSecureAppPreferences {
    enum Key: String, CaseIterable, Equatable {
        case user
        case userName
        case userPIN
        case isAuthenticated
        case isProfileComplete
        case isPrivacyPolicyAccepted
        case isOnboardingCompleted
        case selectedAppearance
    }
}

// MARK: - NonSecureAppPreferences
public class NonSecureAppPreferences {
    public static let shared = NonSecureAppPreferences()

    fileprivate var output = PassthroughSubject<NonSecureAppPreferencesOutputActions, Never>()
    
    fileprivate var cachedBundleIdentifier: String?
    fileprivate var targetEnv: String {
        guard let value = (Bundle.main.infoDictionary?["TARGET_ENVIRONMENT"] as? String)?
            .replacingOccurrences(of: "\\", with: "") else {
            return ""
        }
        return value
    }

    fileprivate var defaults: UserDefaults {
        if let bundleIdentifier = cachedBundleIdentifier, !bundleIdentifier.isEmpty,
           let custom = UserDefaults(suiteName: bundleIdentifier) {
            return custom
        } else {
            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                let fullIdentifier = bundleIdentifier + "_" + targetEnv.lowercased()
                cachedBundleIdentifier = fullIdentifier
                return UserDefaults(suiteName: fullIdentifier) ?? .standard
            } else {
                return .standard
            }
        }
    }
    
    fileprivate func setBool(_ key: NonSecureAppPreferences.Key, _ value: Bool?) {
        defaults.setValue(value, forKey: key.rawValue)
        output.send(.changedKey(key: key))
    }
    
    fileprivate func setString(_ key: NonSecureAppPreferences.Key, _ value: String?) {
        defaults.setValue(value, forKey: key.rawValue)
        output.send(.changedKey(key: key))
    }
}

extension NonSecureAppPreferences: NonSecureAppPreferencesProtocol {
    
    public func output(_ filter: [NonSecureAppPreferencesOutputActions] = []) -> AnyPublisher<NonSecureAppPreferencesOutputActions, Never> {
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
    
    public var nonSecureUserDefaults: UserDefaults {
        defaults
    }

    public func deleteAll() {
        Key.allCases.forEach { key in
            defaults.removeObject(forKey: key.rawValue)
            output.send(.changedKey(key: key))
        }
        output.send(.deletedAll)
    }

    public var isAuthenticated: Bool {
        get { defaults.bool(forKey: Key.isAuthenticated.rawValue) }
        set { setBool(.isAuthenticated, newValue) }
    }

    public var isProfileComplete: Bool {
        get { defaults.bool(forKey: Key.isProfileComplete.rawValue) }
        set { setBool(.isProfileComplete, newValue) }
    }

    public var isPrivacyPolicyAccepted: Bool {
        get { defaults.bool(forKey: Key.isPrivacyPolicyAccepted.rawValue) }
        set { setBool(.isPrivacyPolicyAccepted, newValue) }
    }

    public var isOnboardingCompleted: Bool {
        get { defaults.bool(forKey: Key.isOnboardingCompleted.rawValue) }
        set { setBool(.isOnboardingCompleted, newValue) }
    }

    public var selectedAppearance: String? {
        get { defaults.string(forKey: Key.selectedAppearance.rawValue) }
        set {
            if let newValue = newValue, Common.InterfaceStyle(rawValue: newValue) == nil {
                fatalError("Invalid value: \(newValue)")
            }
            setString(.selectedAppearance, newValue)
        }
    }
}
