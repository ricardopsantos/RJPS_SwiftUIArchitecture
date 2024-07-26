//
//  TermsAndConditionsScreenViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 20/05/2024.
//

import Foundation
import SwiftUI
//
import Common
import Core

@MainActor
class TermsAndConditionsViewModel: ObservableObject {
    enum Actions {
        case didAppear
        case didDisappear
        case doSomething
    }

    @Published var alertModel: Model.AlertModel?
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
    TermsAndConditionsScreen(onCompletion: { _ in })
}
