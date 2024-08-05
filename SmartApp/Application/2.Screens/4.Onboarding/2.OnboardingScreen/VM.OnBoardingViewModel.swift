//
//  OnBoardingViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 20/05/2024.
//

import Foundation
import SwiftUI
//
import Domain
import Common
import Core

//
// MARK: - ViewModel Builder
//

extension OnboardingViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case doSomething
    }
}

class OnboardingViewModel: BaseViewModel {
    // MARK: - Usage Attributes

    // MARK: - Auxiliar Attributes
    private let sampleService: SampleServiceProtocol?
    public init(sampleService: SampleServiceProtocol?) {
        self.sampleService = sampleService
    }

    func send(action: Actions) {
        switch action {
        case .didAppear: ()
        case .didDisappear: ()
        case .doSomething: () // Do something
        }
    }
}

#Preview {
    OnboardingScreen(onCompletion: { _ in }, onBackPressed: {})
}
