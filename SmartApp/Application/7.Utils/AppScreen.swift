//
//  AppScreen.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
import Common

public enum AppScreen: Hashable, Identifiable, Sendable {
    case na
    case splash
    case root
    case mainApp // TabBar
    //
    case login
    case onboarding
    case settings
    case userDetails
    case editUserDetails
    case termsAndConditions
    //
    case templateWith(model: ___Template___Model)
    case weather
    case weatherDetailsWith(model: WeatherDetailsModel)
    case populationNation
    case populationStates(year: String, model: [PopulationStateModel])
    // case mainApp
    public var id: String {
        String(describing: self)
    }
}
