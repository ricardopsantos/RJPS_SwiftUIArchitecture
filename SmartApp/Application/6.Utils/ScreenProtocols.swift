//
//  ScreenProtocols.swift
//  Core
//
//  Created by Ricardo Santos on 20/07/2024.
//

import Foundation
import SwiftUI
//
import Common

/// Protocol to ensure that all ViewCordinators follow the same coding standard
protocol ViewCoordinatorProtocol {
    associatedtype ContentView: View
    var configuration: ConfigurationViewModel { get }
    var router: RouterViewModel { get }
    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> ContentView
}

/// Protocol to ensure that all View follow the same coding standard
protocol ViewProtocol {
    associatedtype ViewModel: ObservableObject
    associatedtype ContentView: View
    associatedtype Dependencies
    var colorScheme: ColorScheme { get }
    var router: RouterViewModel { get }
    var viewModel: ViewModel { get }

    init(dependencies: Dependencies)
    var content: ContentView { get }
}
