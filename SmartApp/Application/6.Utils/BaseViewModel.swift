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
    @Published var alertModel: Model.AlertModel?
    @Published var loadingModel: Model.LoadingModel?
    func handle(error: Error, sender: String) {
        ErrorsManager.handleError(message: sender, error: error)
        if let appError = error as? AppErrors, !appError.localizedForUser.isEmpty {
            alertModel = .init(type: .error, message: appError.localizedForUser)
        } else {
            alertModel = .init(type: .error, message: error.localizedDescription)
        }
        loadingModel = .notLoading
    }
}
