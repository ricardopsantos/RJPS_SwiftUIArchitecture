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
// MARK: - BaseView
//

enum BaseView {
    @ViewBuilder
    static func withLoading<Content: View>(
        sender: String,
        appScreen: AppScreen,
        navigationViewModel: BaseView.NavigationViewModel?,
        ignoresSafeArea: Bool,
        dismissKeyboardOnTap: Bool = false,
        background: BackgroundView.Background,
        displayRenderedView: Bool = Common_Utils.onSimulator,
        loadingModel: Model.LoadingModel?,
        alertModel: Model.AlertModel?,
        networkStatus: CommonNetworking.NetworkStatus?,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        let networkStatus = networkStatus ?? .internetConnectionAvailable
        let existsInternetConnection = networkStatus.existsInternetConnection
        let loadingModel = loadingModel ?? .notLoading
        let existsLoading = loadingModel != .notLoading
        let existsAlert = alertModel != nil
        let doBlur = existsAlert || existsLoading || !existsInternetConnection
        let baseView =
            ZStack {
                BackgroundView(background: background)
                    .doIf(displayRenderedView) {
                        $0.overlay {
                            VStack(spacing: 0) {
                                SwiftUIUtils.RenderedView("\(sender)")
                                    .offset(.init(width: 0, height: -12))
                                    .opacity(displayRenderedView ? 1 : 0)
                                Spacer()
                            }
                        }
                    }
                content()
                    .doIf(!ignoresSafeArea, transform: {
                        $0.padding(.all) // This will ensure the content stays within the safe area
                    })
            }
            .doIf(dismissKeyboardOnTap, transform: {
                $0.onTapDismissKeyboard()
            })
            //
            // Blur
            //
            .blur(radius: doBlur ? 1 : 0)
            .animation(.easeInOut, value: doBlur)
            //
            // Alert Model
            //
            .overlay(
                AlertView(model: alertModel)
                    .ignoresSafeArea()
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .opacity(existsAlert ? 1 : 0)
                    .animation(.easeInOut, value: existsAlert)
            )
            //
            // Loading Model
            //
            .overlay(
                LoadingIndicator(
                    isLoading: loadingModel.isLoading,
                    loadingMessage: loadingModel.message
                )
                .animation(.easeInOut, value: loadingModel)
            )
            //
            // Internet connection
            //
            .overlay(
                ZStack {
                    ColorSemantic.warning.color.opacity(0.2)
                    Text("No Internet connection.\n\nPlease try again latter...".localizedMissing)
                        .fontSemantic(.headlineBold)
                        .textColor(ColorSemantic.labelPrimary.color)
                        .padding()
                        .background(ColorSemantic.warning.color.opacity(1))
                        .multilineTextAlignment(.center)
                        .cornerRadius2(SizeNames.cornerRadius)
                }
                .ignoresSafeArea()
                .opacity(existsInternetConnection ? 0 : 1)
                .animation(.easeInOut, value: existsInternetConnection)
            )
            .onAppear {
                DevTools.Log.debug(DevTools.Log.LogTemplate.screenIn(sender), .view)
                AnalyticsManager.shared.handleScreenIn(appScreen: appScreen)

            }.onDisappear {
                DevTools.Log.debug(DevTools.Log.LogTemplate.screenOut(sender), .view)
            }

        Group {
            if let navigationViewModel = navigationViewModel {
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
                case .defaultHidden:
                    NavigationView {
                        baseView
                    }
                    .hideNavigationBar()
                }
            } else {
                baseView
            }
        }
    }
}

struct TestView: View {
    @State var loadingModel: Model.LoadingModel?
    @State var networkStatus: CommonNetworking.NetworkStatus?
    @State var alertModel: Model.AlertModel?
    @State var text = String.randomWithSpaces(50)
    var animationDuration = 0.3
    var body: some View {
        BaseView.withLoading(
            sender: "sender",
            appScreen: .na,
            navigationViewModel: .disabled,
            ignoresSafeArea: false,
            background: .gradient,
            loadingModel: loadingModel,
            alertModel: alertModel,
            networkStatus: networkStatus,
            content: {
                contentView
            }
        )
    }

    var contentView: some View {
        VStack {
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            Button(action: {
                alertModel = .tryAgainLatter
                Common_Utils.delay(TimeInterval(animationDuration) + 1) {
                    alertModel = nil
                }
            }, label: {
                Text("Alert")
            })
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            Button(action: {
                networkStatus = .internetConnectionLost
                Common_Utils.delay(TimeInterval(animationDuration) + 1) {
                    networkStatus = nil
                }
            }, label: {
                Text("networkStatus")
            })
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            Button(action: {
                loadingModel = .loading(message: "Loading....")
                Common_Utils.delay(TimeInterval(animationDuration) + 1) {
                    loadingModel = nil
                }
            }, label: {
                Text("Loading")
            })
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
            Text(text)
            Spacer()
        }.padding()
    }
}

#Preview("Preview") {
    TestView()
}
