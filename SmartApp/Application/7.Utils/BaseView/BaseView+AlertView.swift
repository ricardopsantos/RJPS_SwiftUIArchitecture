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
        let model: Model.AlertModel?

        public var body: some View {
            Group {
                if let model = model {
                    content
                        .background(
                            baseColor.opacity(0.05) // If the background is not visible, we cant tap it
                                .frame(minWidth: screenWidth)
                        ).onTapGesture {
                            if let parentDismiss = model.parentDismiss {
                                parentDismiss()
                            }
                        }
                } else {
                    EmptyView()
                }
            }
        }

        @ViewBuilder
        var content: some View {
            let margin: CGFloat = SizeNames.defaultMargin * 3
            VStack(spacing: 0) {
                switch model?.location ?? .top {
                case .top:
                    Group {
                        SwiftUIUtils.FixedVerticalSpacer(height: margin)
                        textView
                        Spacer()
                    }
                case .middle:
                    Group {
                        Spacer()
                        textView
                        Spacer()
                    }
                case .bottom:
                    Group {
                        Spacer()
                        textView
                        SwiftUIUtils.FixedVerticalSpacer(height: margin * 2)
                    }
                }
            }.padding()
        }

        var textView: some View {
            Text(model?.message ?? "")
                .fontSemantic(.bodyBold)
                .lineLimit(nil) // Unlimited lines
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true) // Prevents truncation
                .padding()
                .doIf(model?.type == .success, transform: {
                    $0.background(ColorSemantic.allCool.color)
                })
                .doIf(model?.type == .warning, transform: {
                    $0.background(ColorSemantic.warning.color)
                })
                .doIf(model?.type == .error, transform: {
                    $0.background(ColorSemantic.danger.color)
                })
                .cornerRadius(SizeNames.cornerRadius)
                .onTapGesture {
                    if let onUserTapGesture = model?.onUserTapGesture {
                        onUserTapGesture()
                    }
                    if let parentDismiss = model?.parentDismiss {
                        parentDismiss()
                    }
                }
        }

        private var baseColor: Color {
            guard let type = model?.type else {
                return Color.clear
            }
            switch type {
            case .success: return ColorSemantic.allCool.color
            case .warning: return ColorSemantic.warning.color
            case .error: return ColorSemantic.danger.color
            case .information: return ColorSemantic.warning.color
            }
        }
    }
}

struct AlertModelTestView: View {
    @State var alertModel: Model.AlertModel?
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .na,
            navigationViewModel: .disabled,
            ignoresSafeArea: true,
            background: .gradient,
            loadingModel: .notLoading,
            alertModel: alertModel,
            networkStatus: nil,
            content: {
                VStack {
                    Text("\(Model.AlertModel.AlertType.self)")
                        .fontSemantic(.bodyBold)
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
                    ForEach(Model.AlertModel.AlertType.allCases, id: \.self) { type in
                        Button("\(type)") {
                            alertModel = .init(
                                type: type,
                                message: type.rawValue,
                                onUserTapGesture: {
                                    alertModel = nil
                                }
                            )
                            Common_Utils.delay(5) {
                                alertModel = nil
                            }
                        }
                    }
                }
            }
        )
    }
}

#Preview("Preview") {
    AlertModelTestView()
}
