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
    // Generic
    case splash
    case root
    case mainApp // TabBar
    // HitHappens app
    case favoriteEvents
    case eventsList
    case eventLogs
    //
    case templateWith(model: ___Template___Model)
    // Template App
    case login
    case onboarding
    case settings
    case userDetails
    case editUserDetails
    case termsAndConditions
    case weather
    case weatherDetailsWith(model: WeatherDetailsModel)
    case populationNation
    case populationStates(year: String, model: [PopulationStateModel])
    public var id: String {
        String(describing: self)
    }
}
