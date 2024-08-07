//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import Foundation
import SwiftUI
import Combine

// swiftlint:disable all

// https://peterfriese.dev/swift-combine-love/

extension SwiftUITipsAndTricks {
    //
    // MARK: - ViewModel
    //

    class PasswordCheckerViewModel: ObservableObject {
        enum PasswordStrength {
            case reasonable
            case strong
            case veryStrong
            case weak
        }

        enum PasswordCheck {
            case valid
            case empty
            case noMatch
            case notStrongEnough
        }

        //
        // input
        //
        @Published var username = ""
        @Published var password = ""
        @Published var passwordAgain = ""

        //
        // output
        //
        @Published var usernameMessage = ""
        @Published var passwordMessage = ""
        @Published var isValid = false

        private var cancelBag = CancelBag()
        init() {
            isUsernameValid
                .receive(on: RunLoop.main)
                .map { valid in valid ? "" : "User name must at least have 3 characters" }
                .assign(to: \.usernameMessage, on: self)
                .store(in: cancelBag)

            isPasswordValid
                .receive(on: RunLoop.main)
                .map { passwordCheck in
                    switch passwordCheck {
                    case .empty: "Password must not be empty"
                    case .noMatch: "Passwords don't match"
                    case .notStrongEnough: "Password not strong enough"
                    default: ""
                    }
                }
                .assign(to: \.passwordMessage, on: self)
                .store(in: cancelBag)

            isFormValid
                .receive(on: RunLoop.main)
                .assign(to: \.isValid, on: self)
                .store(in: cancelBag)
        }

        private var isUsernameValid: AnyPublisher<Bool, Never> {
            $username
                .debounce(for: 0.8, scheduler: RunLoop.main)
                .removeDuplicates()
                .map { input in input.count >= 3 }
                .eraseToAnyPublisher()
        }

        private var isPasswordEmpty: AnyPublisher<Bool, Never> {
            $password
                .debounce(for: 0.8, scheduler: RunLoop.main)
                .removeDuplicates()
                .map { password in password == "" }
                .eraseToAnyPublisher()
        }

        private var arePasswordsEqual: AnyPublisher<Bool, Never> {
            Publishers.CombineLatest($password, $passwordAgain)
                .debounce(for: 0.2, scheduler: RunLoop.main)
                .map { password, passwordAgain in password == passwordAgain }
                .eraseToAnyPublisher()
        }

        private var passwordStrength: AnyPublisher<PasswordCheckerViewModel.PasswordStrength, Never> {
            $password
                .debounce(for: 0.2, scheduler: RunLoop.main)
                .removeDuplicates()
                .map { input in
                    input.count > 8 ? .strong : .weak
                }
                .eraseToAnyPublisher()
        }

        private var isPasswordStrongEnough: AnyPublisher<Bool, Never> {
            passwordStrength
                .map { strength in
                    switch strength {
                    case .reasonable,
                         .strong,
                         .veryStrong: true
                    default: false
                    }
                }
                .eraseToAnyPublisher()
        }

        private var isPasswordValid: AnyPublisher<PasswordCheckerViewModel.PasswordCheck, Never> {
            Publishers.CombineLatest3(isPasswordEmpty, arePasswordsEqual, isPasswordStrongEnough)
                .map { passwordIsEmpty, passwordsAreEqual, passwordIsStrongEnough in
                    if passwordIsEmpty {
                        .empty
                    }
                    else if !passwordsAreEqual {
                        .noMatch
                    }
                    else if !passwordIsStrongEnough {
                        .notStrongEnough
                    }
                    else {
                        .valid
                    }
                }
                .eraseToAnyPublisher()
        }

        private var isFormValid: AnyPublisher<Bool, Never> {
            Publishers.CombineLatest(isUsernameValid, isPasswordValid)
                .map { userNameIsValid, passwordIsValid in userNameIsValid && (passwordIsValid == .valid) }
                .eraseToAnyPublisher()
        }
    }

    //
    // MARK: - View
    //

    struct PasswordCheckerView: View {
        @ObservedObject var vm = SwiftUITipsAndTricks.PasswordCheckerViewModel()
        @State var presentAlert = false

        var body: some View {
            Form {
                Section(footer: Text(vm.usernameMessage).foregroundColor(.red)) {
                    TextField("Username", text: $vm.username).autocapitalization(.none)
                }
                Section(footer: Text(vm.passwordMessage).foregroundColor(.red)) {
                    SecureField("Password", text: $vm.password)
                    SecureField("Password again", text: $vm.passwordAgain)
                }
                Section {
                    Button(action: { presentAlert.toggle() }) { Text("Sign up") }.disabled(!vm.isValid)
                }
            }
            .sheet(isPresented: $presentAlert) {
                SwiftUITipsAndTricks.WelcomeView()
            }
        }
    }

    struct WelcomeView: View {
        var body: some View {
            Text("Welcome! Great to have you on board!")
        }
    }
}

//
// MARK: - Preview
//
#if canImport(SwiftUI) && DEBUG
#Preview {
    SwiftUITipsAndTricks.PasswordCheckerView()
}
#endif
