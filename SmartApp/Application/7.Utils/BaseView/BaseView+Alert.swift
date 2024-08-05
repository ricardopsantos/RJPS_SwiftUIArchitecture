//
//  AlertView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 03/08/2024.
//

import Foundation
import SwiftUI
//
import DesignSystem
import Common
import DevTools

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
            dismissed = true
        }

        var content: some View {
            Group {
                if let model = model {
                    VStack(spacing: 0) {
                        SwiftUIUtils.FixedVerticalSpacer(height: extraH)
                        Text(model.message)
                            .fontSemantic(.bodyBold)
                            .lineLimit(nil) // Unlimited lines
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true) // Prevents truncation
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
