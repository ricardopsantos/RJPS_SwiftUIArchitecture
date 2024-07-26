//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import Foundation
import SwiftUI
import Combine

//
// https://azamsharp.medium.com/environmentobject-in-views-may-not-be-a-good-idea-but-avoiding-them-is-probably-much-worse-f5461cfb218
//

//
// MARK: AppState
//

//
// MARK: DisplayCounterViewModel
//

extension SampleCounterDomain {
    class DisplayCounterViewModel: SampleCounterV4_DisplayCounterProtocol {
        private var appState: SampleCounterDomain.AppState
        init(appState: SampleCounterDomain.AppState) {
            self.appState = appState
        }

        var count: Int {
            appState.counterValue
        }
    }
}

//
// MARK: DisplayCounterView
//
extension SampleCounterDomain {
    struct DisplayCounterView_V1: View {
        let viewModel: SampleCounterV4_DisplayCounterProtocol
        init(viewModel: any SampleCounterV4_DisplayCounterProtocol) {
            self.viewModel = viewModel
        }

        var body: some View {
            VStack {
                SwiftUIUtils.RenderedView("DisplayCounterView_V1")
                Text("DisplayCounterViewV1").font(.body)
                Text("Value: \(viewModel.count)").font(.caption)
            }
        }
    }
}

//
// MARK: IncrementCounterView
//

extension SampleCounterDomain {
    class IncrementCounterViewModel: SampleCounterV4_IncrementCounterProtocol {
        var appState: SampleCounterDomain.AppState
        init(appState: SampleCounterDomain.AppState) {
            self.appState = appState
        }

        func increment() {
            appState.counterValue += 1
        }
    }
}

//
// MARK: IncrementCounterView
//

public extension SampleCounterDomain {
    struct IncrementCounterView_V1: View {
        let viewModel: SampleCounterV4_IncrementCounterProtocol
        init(viewModel: any SampleCounterV4_IncrementCounterProtocol) {
            self.viewModel = viewModel
        }

        public var body: some View {
            VStack {
                SwiftUIUtils.RenderedView("IncrementCounterView_V1")
                Text("IncrementCounterView_V1").font(.body)
                Button("Increment_V1") {
                    viewModel.increment()
                }
            }
        }
    }

    struct IncrementCounterView_V2: View {
        @EnvironmentObject var counterState: CounterState
        public var body: some View {
            VStack {
                SwiftUIUtils.RenderedView("IncrementCounterView_V2")
                Text("IncrementCounterView_V2").font(.body)
                Button("Increment_V2") {
                    counterState.count += 1
                }
            }
        }
    }

    //
    // MARK: AuthView & ParentView:
    //

    struct AuthView: View {
        @EnvironmentObject var authState: AuthState
        public var body: some View {
            VStack {
                SwiftUIUtils.RenderedView("AuthView")
                Text(authState.isAuthenticated ? "Auth" : "Not Auth")
                Button("Toggle auth") {
                    authState.isAuthenticated.toggle()
                }
            }
        }
    }

    struct DisplayCounterView_V2: View {
        public var body: some View {
            VStack {
                SwiftUIUtils.RenderedView("DisplayCounterView_V2")
                Text("DisplayCounterView_V2").font(.body)
                DisplayCounterChildView_V2()
            }
        }

        struct DisplayCounterChildView_V2: View {
            @EnvironmentObject var counterState: CounterState
            @EnvironmentObject var authState: AuthState
            var body: some View {
                VStack {
                    SwiftUIUtils.RenderedView("DisplayCounterChildView_V2")
                    Text("\(counterState.count) | \(authState.isAuthenticated.description)")
                }
            }
        }
    }

    //
    // MARK: - Main View
    //

    struct SampleCounterV4_View: View {
        @EnvironmentObject var appState: AppState

        public var body: some View {
            VStack(spacing: 5) {
                SwiftUIUtils.RenderedView("SampleCounterV4_View")
                    .background(Color.random.opacity(0.15))
                Divider()
                //
                // Injecting state via dependency injection view model
                //
                VStack {
                    HStack { Spacer() }
                    Text("Injecting state via dependency injection view model")
                    DisplayCounterView_V1(viewModel: DisplayCounterViewModel(appState: appState))
                        .background(Color.green)
                    IncrementCounterView_V1(viewModel: IncrementCounterViewModel(appState: appState))
                        .background(Color.red)
                }.background(Color.yellow)
                Divider()
                //
                // Injecting state via EnvironmentObject
                //
                VStack {
                    HStack { Spacer() }
                    Text("Injecting state via EnvironmentObject")
                    DisplayCounterView_V2()
                        .environmentObject(appState.counterState)
                        .environmentObject(appState.authState)
                        .background(Color.green)
                    IncrementCounterView_V2()
                        .environmentObject(appState.counterState)
                        .background(Color.red)
                    AuthView()
                        .environmentObject(appState.authState)
                        .background(Color.blue)
                }.background(Color.orange)

                Spacer()
            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
public enum SampleCounterV4_Preview: PreviewProvider {
    static let appState = SampleCounterDomain.AppState()
    public static var previews: some View {
        SampleCounterDomain.SampleCounterV4_View()
            .environmentObject(appState)
    }
}
#endif
