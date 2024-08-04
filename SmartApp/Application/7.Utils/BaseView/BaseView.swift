//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
//
import DevTools
import Common
import DesignSystem
import Core

//
// MARK: - SwiftUIFactory
//

enum BaseView {
    @ViewBuilder
    static func withLoading<Content: View>(
        sender: String,
        appScreen: AppScreen,
        navigationViewModel: BaseView.NavigationViewModel,
        ignoresSafeArea: Bool = false,
        dismissKeyboardOnTap: Bool = false,
        background: BackgroundView.Background,
        displayRenderedView: Bool = Common_Utils.onSimulator,
        loadingModel: Model.LoadingModel?,
        alertModel: Model.AlertModel?,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        baseWith(
            sender: sender,
            appScreen: appScreen,
            navigationViewModel: navigationViewModel,
            ignoresSafeArea: ignoresSafeArea,
            dismissKeyboardOnTap: dismissKeyboardOnTap,
            background: background,
            displayRenderedView: displayRenderedView,
            alertModel: alertModel
        ) {
            Group {
                if let loadingModel = loadingModel {
                    ZStack {
                        content().opacity(loadingModel.isLoading ? 0.1 : 1)
                        LoadingIndicator(
                            isLoading: loadingModel.isLoading,
                            loadingMessage: loadingModel.message
                        )
                    }
                } else {
                    content()
                }
            }
        }
    }
}

//
// MARK: - Private
//
fileprivate extension BaseView {
    @ViewBuilder
    static func baseWith<Content: View>(
        sender: String,
        appScreen: AppScreen,
        navigationViewModel: BaseView.NavigationViewModel,
        ignoresSafeArea: Bool,
        dismissKeyboardOnTap: Bool,
        background: BackgroundView.Background,
        displayRenderedView: Bool,
        alertModel: Model.AlertModel?,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        var baseView =
            ZStack {
                BackgroundView(background: background)
                VStack(spacing: 0) {
                    SwiftUIUtils.RenderedView("\(sender)").opacity(displayRenderedView ? 1 : 0)
                    Spacer()
                }
                content()
                if let alertModel = alertModel {
                    AlertView(model: alertModel, opacity: 1)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                        .doIf(ignoresSafeArea, transform: {
                            $0.ignoresSafeArea()
                        })
                }
            }
            .doIf(dismissKeyboardOnTap, transform: {
                $0.onTapDismissKeyboard()
            })
            .onAppear {
                DevTools.Log.debug(DevTools.Log.LogTemplate.screenIn(sender), .view)
                AnalyticsManager.shared.handleScreenIn(appScreen: appScreen)

            }.onDisappear {
                DevTools.Log.debug(DevTools.Log.LogTemplate.screenOut(sender), .view)
            }

        Group {
            switch navigationViewModel.type {
            case .disabled:
                baseView
            case .custom:
                NavigationView {
                    baseView
                }.customBackButtonV1(action: {
                    if let onBackButtonTap = navigationViewModel.onBackButtonTap {
                        onBackButtonTap()
                    }
                }, title: navigationViewModel.title)
            case .default:
                NavigationView {
                    baseView
                }
                .navigationTitle(navigationViewModel.title)
            }
        }
    }
}

#Preview("Preview") {
    BaseView.withLoading(
        sender: "sender",
        appScreen: .na,
        navigationViewModel: .disabled,
        ignoresSafeArea: true,
        background: .gradient,
        loadingModel: .notLoading,
        //   loadingModel: .loading(message: "Loading".localizedMissing, id: UUID().uuidString),
        //  alertModel: .noInternet,
        alertModel: nil,
        content: {
            Text("Content")
        }
    )
}
