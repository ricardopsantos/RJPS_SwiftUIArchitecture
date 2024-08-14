//
//  SampleCounter.swift
//  Common
//
//  Created by Ricardo Santos on 28/03/2024.
//

import Foundation
import SwiftUI

//
// MARK: Protocols
//

public protocol SampleCounterV3_ViewModelProtocol: ObservableObject {
    var count: Int { get set }
    func increment()
}

protocol SampleCounterV4_DisplayCounterProtocol {
    var count: Int { get }
}

protocol SampleCounterV4_IncrementCounterProtocol {
    func increment()
}

//
// MARK: SampleCounterDomain
//

public enum SampleCounterDomain {
    public static var startValue: Int = 10

    class AppState: ObservableObject {
        @Published var counterValue: Int = SampleCounterDomain.startValue
        var counterState = CounterState()
        var authState = AuthState()
    }

    class AuthState: ObservableObject {
        @Published var isAuthenticated: Bool = false
    }

    public enum SampleCounter_Model {
        public static func increment(count: Int) -> Int { count + 1 }
    }

    class CounterState: ObservableObject {
        @Published var count: Int = SampleCounterDomain.startValue
    }

    public class SampleCounter_ViewModel: ObservableObject {
        @Published var count: Int
        public init(count: Int) {
            self.count = count
        }

        public func increment() {
            count = SampleCounter_Model.increment(count: count)
        }
    }
}

//
// MARK: SampleCounterShared
//

public enum SampleCounterShared {
    @ViewBuilder
    static func displayView(
        title: String,
        counterValue: Binding<Int>,
        onTap: @autoclosure @escaping () -> Void) -> some View {
        VStack {
            Divider()
            SwiftUIUtils.RenderedView("Shared Display View")
            Text(title)
                .font(.body)
            Divider()
            VStack {
                Text(counterValue.wrappedValue.description)
                Button("Increment", action: { onTap() })
            }
        }
    }
}
