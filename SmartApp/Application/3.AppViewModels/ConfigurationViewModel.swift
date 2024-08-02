//
//  Configuration.swift
//  SmartApp
//
//  Created by Ricardo Santos on 19/07/2024.
//

import Foundation
//
import Domain
import Core

// ConfigurationViewModel is `ObservableObject` so that we can inject it on the view hierarchy
@MainActor
class ConfigurationViewModel: ObservableObject {
    // MARK: - Dependency Attributes
    let dataUSAService: DataUSAServiceProtocol

    // MARK: - Constructor
    init(dataUSAService: DataUSAServiceProtocol) {
        self.dataUSAService = dataUSAService
    }
}

// MARK: - Previews

extension ConfigurationViewModel {
    static var defaultForPreviews: ConfigurationViewModel {
        ConfigurationViewModel(
            dataUSAService: DependenciesManager.Services.dataUSAServiceMock
        )
    }
}
