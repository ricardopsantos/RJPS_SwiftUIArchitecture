//
//  PopulationStateViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 02/08/2024.
//

import Foundation
import SwiftUI
//
import Domain
import Common
import Core

//
// MARK: - Model
//

struct PopulationStateModel: Equatable, Hashable {
    let stateID: String
    let year: String

    init(stateID: String = "", year: String = "") {
        self.stateID = stateID
        self.year = year
    }
}
