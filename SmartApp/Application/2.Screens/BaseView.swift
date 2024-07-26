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

// swiftlint:disable no_UIKitAdhocConstruction

//
// MARK: - SwiftUIFactory
//

enum BaseView {
    @ViewBuilder
    static func with<Content: View>(
        sender: String,
        appScreen: AppScreen,
        navigationViewEmbed: Bool,
        scrollViewEmbed: Bool,
        ignoresSafeArea: Bool,
        dismissKeyboardOnTap: Bool = true,
        background: BackgroundView.Background,
        displayRenderedView: Bool = true,
        alertModel: Model.AlertModel? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ZStack {
            BackgroundView(background: background)
            VStack(spacing: 0) {
                SwiftUIUtils.RenderedView("\(sender)").opacity(displayRenderedView ? 1 : 0)
                Spacer()
            }
            Group {
                if scrollViewEmbed {
                    if navigationViewEmbed {
                        NavigationView {
                            ScrollView {
                                content()
                            }.background(BackgroundView(background: background).edgesIgnoringSafeArea(.all))
                        }
                    } else {
                        ScrollView {
                            content()
                        }
                    }
                } else {
                    if navigationViewEmbed {
                        NavigationView {
                            content()
                                .background(BackgroundView().edgesIgnoringSafeArea(.all))
                        }
                    } else {
                        content()
                    }
                }
            }
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
            BackgroundServicesManager.shared.handleEvent(
                .viewLifeCycle(.viewDidAppear(appScreen: appScreen)), nil
            )
        }.onDisappear {
            DevTools.Log.debug(DevTools.Log.LogTemplate.screenOut(sender), .view)
            BackgroundServicesManager.shared.handleEvent(
                .viewLifeCycle(.viewDidDisappear(appScreen: appScreen)), nil
            )
        }
    }

    @ViewBuilder
    static func withLoading<Content: View>(
        sender: String,
        appScreen: AppScreen,
        navigationViewEmbed: Bool,
        scrollViewEmbed: Bool,
        ignoresSafeArea: Bool,
        dismissKeyboardOnTap: Bool = false,
        background: BackgroundView.Background,
        displayRenderedView: Bool = false,
        loadingModel: Model.LoadingModel?,
        alertModel: Model.AlertModel? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        with(
            sender: sender,
            appScreen: appScreen,
            navigationViewEmbed: navigationViewEmbed,
            scrollViewEmbed: scrollViewEmbed,
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
// MARK: - AlertView
//

extension BaseView {
    struct AlertView: View {
        @Environment(\.colorScheme) var colorScheme
        @State var model: Model.AlertModel?
        @State var opacity: Double = 1
        @Environment(\.presentationMode) var presentation
        @State var dismissed: Bool = false

        private var visibleTime: CGFloat {
            guard let model = model else {
                return 0
            }
            let defaultTime: CGFloat = 3
            switch model.type {
            case .success: return defaultTime
            case .warning: return defaultTime * 1.5
            case .error: return DevTools.onSimulator ? defaultTime : defaultTime * 2
            case .information: return defaultTime
            }
        }

        private var baseColor: Color {
            guard let model = model else {
                return .clear
            }
            switch model.type {
            case .success: return ColorSemantic.allCool.color
            case .warning: return ColorSemantic.warning.color
            case .error: return ColorSemantic.danger.color
            case .information: return ColorSemantic.warning.color
            }
        }

        let extraH: CGFloat = SizeNames.defaultMargin * 3
        public var body: some View {
            if Common_Utils.true {
                // swiftlint:disable no_letUnderscore redundant_discardable_let
                let _ = Self._printChanges()
                // swiftlint:enable no_letUnderscore redundant_discardable_let
            }
            Group {
                if model != nil {
                    ZStack {
                        content
                    }.background(
                        baseColor.opacity(0.1) // If the background is not visible, we cant tap it
                            .frame(minWidth: screenWidth)
                    )
                    .onAppear {
                        Common_Utils.delay(visibleTime) {
                            dismiss()
                        }
                    }.onTapGesture {
                        dismiss()
                    }
                } else {
                    EmptyView()
                }
            }
        }

        func dismiss() {
            guard !dismissed else { return }
            if let onDismiss = model?.onDismiss {
                onDismiss()
            }
            opacity = 0
            model = nil
            // if !dismissed {
            //     /// https://www.swiftbysundell.com/articles/dismissing-swiftui-modal-and-detail-views/
            //    presentation.wrappedValue.dismiss()
            // }
            dismissed = true
        }

        var content: some View {
            Group {
                if let model = model {
                    VStack(spacing: 0) {
                        SwiftUIUtils.FixedVerticalSpacer(height: extraH)
                        Text(model.message)
                            .fontSemantic(.bodyBold)
                            .lineLimit(0)
                            .padding()
                            .doIf(model.type == .success, transform: {
                                $0.background(ColorSemantic.allCool.color)
                            })
                            .doIf(model.type == .warning, transform: {
                                $0.background(ColorSemantic.warning.color)
                            })
                            .doIf(model.type == .error, transform: {
                                $0.background(ColorSemantic.danger.color)
                            })
                            .cornerRadius(SizeNames.cornerRadius)
                        Spacer()
                    }
                    .padding()
                } else {
                    EmptyView()
                }
            }
            .background(Color.clear)
            .opacity(opacity)
            .defaultAnimation()
        }
    }
}

//
// MARK: - BackgroundView
//

extension BaseView.BackgroundView {
    enum Background {
        case clear
        case linear
        case gradient
    }
}

extension BaseView {
    struct BackgroundView: View {
        var background: Background = .gradient
        @Environment(\.colorScheme) var colorScheme
        public var body: some View {
            Group {
                switch background {
                case .clear:
                    Color.clear
                case .linear:
                    backgroundLinear
                case .gradient:
                    backgroundGradient
                }
            }
        }

        var backgroundLinear: some View {
            // Color.white
            ColorSemantic.backgroundPrimary.color.ignoresSafeArea()
        }

        var backgroundGradient: some View {
            LinearGradient(
                colors: [
                    ColorSemantic.backgroundPrimary.color,
                    ColorSemantic.backgroundGradient.color
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
        }
    }
}

#Preview("Preview") {
    BaseView.withLoading(
        sender: "sender",
        appScreen: .na,
        navigationViewEmbed: false,
        scrollViewEmbed: false,
        ignoresSafeArea: true,
        background: .gradient,
        loadingModel: .notLoading,
//        loadingModel: .loading(message: "Loading".localizedMissing, id: UUID().uuidString),
        alertModel: .noInternet,
        content: {
            Text("Content")
        }
    )
}
