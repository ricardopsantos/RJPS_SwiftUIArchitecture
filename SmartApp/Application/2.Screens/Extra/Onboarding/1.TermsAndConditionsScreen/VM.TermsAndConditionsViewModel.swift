//
//  TermsAndConditionsScreenViewModel.swift
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

extension TermsAndConditionsViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case doSomething
    }
}

class TermsAndConditionsViewModel: BaseViewModel {
    // MARK: - Usage/Auxiliar Attributes
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

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    TermsAndConditionsScreen(onCompletion: { _ in })
}
#endif
