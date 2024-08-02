//
//  AppScreen.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
import Common

enum AppScreen: Hashable, Identifiable {
    case na
    case splash
    case root
    case populationNation
    case populationStates(year: String, model: [PopulationStateModel])
    // case mainApp
    var id: String {
        String(describing: self)
    }
}
