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
import DevTools

@MainActor
public class BaseViewModel: ObservableObject {
    // Published properties to trigger UI updates when values change
    @Published var alertModel: Model.AlertModel? {
        didSet {
            
            var visibleTime: CGFloat {
                guard let alertModel = alertModel else {
                    return 0
                }
                let defaultTime: CGFloat = 3
                switch alertModel.type {
                case .success: return defaultTime
                case .warning: return defaultTime * 1.5
                case .error: return DevTools.onSimulator ? defaultTime : defaultTime * 2
                case .information: return defaultTime
                }
            }
            
            // If alertModel is not nil, schedule it to be set to nil after 5 seconds
            if alertModel != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + visibleTime) { [weak self] in
                    // Check if alertModel is still the same as before to prevent race conditions
                    self?.alertModel = nil
                }
            }
        }
    }
    @Published var loadingModel: Model.LoadingModel?

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
