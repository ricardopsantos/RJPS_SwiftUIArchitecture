//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import LocalAuthentication
import SwiftUI
import Combine

//
// MARK: - AuthManagerViewModel
//

public extension Common {
    class AuthManagerViewModel: ObservableObject {
        public enum UserFriendlyError: Error {
            case none
            case unknown
            case deniedByUser
            case userDidCanceledOnEnrolledBiometryPrompt
            case userDidNotEnrolledBiometry
        }

        deinit {
            context = nil
        }

        fileprivate var context: LAContext?
        fileprivate var error: UserFriendlyError = .none
        private init() {
            self.context = LAContext()
        }

        public static var shared = AuthManagerViewModel()
        @Published public private(set) var biometricType: LABiometryType = .none // faceID, touchId, none
        @Published public private(set) var userIsAuthenticated: Bool = false
        @Published public private(set) var userNeedsToAllowPermissionOnAppSettings: Bool = false
        @Published public private(set) var userNeedsToEnrollBiometry: Bool = false
        public func start() {
            checkBiometricAvailability { [weak self] userFriendlyError in
                self?.handle(userFriendlyError: userFriendlyError)
            }
        }

        public func authenticate(_ reason: String) {
            authenticate(reason: reason) { _ in }
        }
    }
}

//
// MARK: - Private
//

fileprivate extension Common.AuthManagerViewModel {
    func handle(userFriendlyError: UserFriendlyError?) {
        guard let userFriendlyError else {
            error = .none
            userNeedsToAllowPermissionOnAppSettings = false
            userNeedsToEnrollBiometry = false
            return
        }
        guard userFriendlyError != error else {
            return
        }
        userIsAuthenticated = false
        error = userFriendlyError
        userNeedsToAllowPermissionOnAppSettings = userFriendlyError == .deniedByUser
        userNeedsToEnrollBiometry = userFriendlyError == .userDidNotEnrolledBiometry

        switch userFriendlyError {
        case .none: ()
        case .unknown: ()
        case .deniedByUser:
            biometricType = .none
        case .userDidCanceledOnEnrolledBiometryPrompt: ()
        case .userDidNotEnrolledBiometry:
            authenticate("userDidNotEnrolledBiometry")
        }
    }

    func checkBiometricAvailability(completion: @escaping (UserFriendlyError?) -> Void) {
        guard let context else {
            return
        }
        var nsError: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &nsError) {
            biometricType = context.biometryType
        } else {
            handle(userFriendlyError: Self.userFriendlyErrorWith(error: nsError))
            completion(error)
        }
    }

    func authenticate(reason: String, completion: @escaping (Result<Bool, UserFriendlyError>) -> Void) {
        guard let context else {
            return
        }
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, nsError in
            Common_Utils.executeInMainTread {
                if let nsError {
                    self?.handle(userFriendlyError: Self.userFriendlyErrorWith(error: nsError as NSError))
                    completion(.failure(self?.error ?? .none))
                } else if success {
                    self?.userIsAuthenticated = true
                    self?.handle(userFriendlyError: nil)
                    completion(.success(true))
                } else {
                    Common.LogsManager.error("Not and error and not success")
                }
            }
        }
    }

    static func userFriendlyErrorWith(error: NSError?) -> UserFriendlyError {
        guard let error = error as? LAError else {
            return .none
        }
        let ignoreLog = error.code == .biometryNotEnrolled && Common_Utils.onSimulator
        if !ignoreLog {
            Common.LogsManager.error("\(error.code) | \(error.localizedDescription)")
        }
        switch error.code {
        case .userCancel:
            // The user tapped the cancel button in the authentication dialog.
            // After failed autentication the first time, use choose to cancel instead of repeat
            return .userDidCanceledOnEnrolledBiometryPrompt
        case .biometryNotAvailable:
            // Biometry is not available on the device. User has denied the use of biometry for this app.
            // When prompt with alert to allow Biometry, the user choose "Dont allow"
            return .deniedByUser
        case .biometryNotEnrolled: () // The user has no enrolled biometric identities.
            return .userDidNotEnrolledBiometry
        case .authenticationFailed: () // The user failed to provide valid credentials.
        case .userFallback: () // The user tapped the fallback button in the authentication dialog
        case .systemCancel: () // The system canceled authentication.
        case .passcodeNotSet: () // A passcode isn’t set on the device.
        case .biometryNotPaired: () // The device supports biometry only using a removable accessory
        case .biometryDisconnected: () // The device supports biometry only using a removable accessory
        case .biometryLockout: () // Biometry is locked because there were too many failed attempts.
        case .appCancel: () // The app canceled authentication.
        case .invalidContext: () // The context was previously invalidated.
        case .notInteractive: () // Displaying the required authentication user interface is forbidden.
        case .watchNotAvailable: () // An attempt to authenticate with Apple Watch failed.
        default: ()
        }
        return .unknown
    }
}
