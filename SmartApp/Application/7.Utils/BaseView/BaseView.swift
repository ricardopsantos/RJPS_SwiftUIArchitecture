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
        networkStatus: CommonNetworking.NetworkStatus?,
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
            alertModel: alertModel,
            networkStatus: networkStatus
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
        networkStatus: CommonNetworking.NetworkStatus?,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        let baseView =
            ZStack {
                BackgroundView(background: background)
                VStack(spacing: 0) {
                    SwiftUIUtils.FixedVerticalSpacer(height: 0.1)
                    SwiftUIUtils.RenderedView("\(sender)")
                        .offset(.init(width: 0, height: -12))
                        .opacity(displayRenderedView ? 1 : 0)
                    Spacer()
                }
                content()
                if let alertModel = alertModel {
                    AlertView(model: alertModel)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                        .doIf(ignoresSafeArea, transform: {
                            $0.ignoresSafeArea()
                        })
                }
            }
            .doIf(dismissKeyboardOnTap, transform: {
                $0.onTapDismissKeyboard()
            })
            .doIf(!(networkStatus?.existsInternetConnection ?? true), transform: {
                $0.opacity(0.1).overlay(
                    ZStack {
                        ColorSemantic.warning.color.opacity(0.2)
                        Text("No Internet connection.\n\nPlease try again latter...".localizedMissing)
                            .fontSemantic(.callout)
                            .textColor(ColorSemantic.danger.color)
                            .multilineTextAlignment(.center)
                    }
                )
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
            case .enabledHidden:
                NavigationView {
                    baseView
                }
                .hideNavigationBar()
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
        alertModel: nil /* .noInternet */,
        networkStatus: .internetConnectionLost,
        content: {
            Text("\(String.randomWithSpaces(1000))")
        }
    )
}
