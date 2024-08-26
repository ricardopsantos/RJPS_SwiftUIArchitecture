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
    var coordinator: RouterViewModel { get }
    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> ContentView
}

/// Protocol to ensure that all View follow the same coding standard
protocol ViewProtocol {
    /**
     __Code division template__
     ```
     // MARK: - ViewProtocol
     @Environment(\.colorScheme) var colorScheme
     @StateObject var viewModel: SomeViewModel
     public init(dependencies: SomeViewModel.Dependencies) {
         DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
         _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
     }

     // MARK: - Usage/Auxiliar Attributes
     @Environment(\.dismiss) var dismiss
     @State private var animatedGradient = true
     let cancelBag = CancelBag()

     var body: some View {
         BaseView {
             content
         }.onAppear {
             viewModel.send(action: .didAppear)
         }.onDisappear {
             viewModel.send(action: .didDisappear)
         }
     }

     var content: some View {
            ...
     }
     ```
     */

    associatedtype ViewModel: ObservableObject
    associatedtype ContentView: View
    associatedtype Dependencies
    var colorScheme: ColorScheme { get }
    var viewModel: ViewModel { get }

    init(dependencies: Dependencies)
    var content: ContentView { get }
}
