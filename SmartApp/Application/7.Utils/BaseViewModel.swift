//
//  BaseViewModel.swift
//  SmartAppUITests
//
//  Created by Ricardo Santos on 03/08/2024.
//

import Foundation
//
import Common
import Domain

@MainActor
public class BaseViewModel: ObservableObject {
    // Published properties to trigger UI updates when values change
    @Published var alertModel: Model.AlertModel?
    @Published var loadingModel: Model.LoadingModel?

    // Function to handle errors
    func handle(error: Error, sender: String) {
        // Handle the error using a custom error manager
        ErrorsManager.handleError(message: sender, error: error)
        
        // Check if the error is of type AppErrors and has a user-friendly message
        if let appError = error as? AppErrors, !appError.localizedForUser.isEmpty {
            // Set the alert model with the user-friendly error message
            alertModel = .init(type: .error, message: appError.localizedForUser)
        } else {
            // Set the alert model with the error's localized description
            alertModel = .init(type: .error, message: error.localizedDescription)
        }
        
        // Set the loading model to indicate loading has stopped
        loadingModel = .notLoading
    }
}
