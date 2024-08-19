//
//  BaseViewModel.swift
//  SmartAppUITests
//
//  Created by Ricardo Santos on 03/08/2024.
//

import Foundation
import SwiftUI
//
import Common
import Domain
import DevTools

@MainActor
public class BaseViewModel: ObservableObject {
    // MARK: - Usage Attributes
    @Published var loadingModel: Model.LoadingModel?
    @Published var alertModel: Model.AlertModel? {
        didSet {
            guard var alertModel = alertModel else {
                return
            }
            if alertModel.parentDismiss == nil {
                // Append dismissAlert to the onDismiss closure
                alertModel.parentDismiss = { [weak self] in
                    self?.alertModel = nil
                }

                print("Is not dismissing on the tap")
                // Set the alertModel back with the updated onDismiss
                self.alertModel = alertModel
                return
            }

            Common.ExecutionControlManager.debounce(
                alertModel.visibleTime,
                operationId: "\(Self.self)_\(#function)"
            ) { [weak self] in
                self?.alertModel = nil
            }
        }
    }

    // MARK: - Helpers

    // Function to handle errors
    func handle(error: Error, sender: String) {
        // Set the loading model to indicate loading has stopped
        loadingModel = .notLoading

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
    }
}
