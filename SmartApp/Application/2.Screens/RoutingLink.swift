//
//  RootView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
import Common

enum AppScreen: Hashable, Identifiable {
    case na
    case template
    case templateWith(model: ___Template___Model)
    case splash
    case root
    case mainApp // TabBar
    case login
    case onboarding
    case weather
    case settings
    case weatherDetailsWith(model: WeatherDetailsModel)
    case userDetails
    case editUserDetails
    case termsAndConditions
    case populationNation
    case populationState(model: PopulationStateModel)
    // case mainApp
    var id: String {
        String(describing: self)
    }
}
