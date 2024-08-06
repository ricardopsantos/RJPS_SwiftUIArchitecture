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
        @State var model: Model.AlertModel
        @State var dismissed: Bool = false

        public var body: some View {
            ZStack {
                content
            }.background(
                baseColor.opacity(0.05) // If the background is not visible, we cant tap it
                    .frame(minWidth: screenWidth)
            )
            .opacity(dismissed ? 0 : 1)
            .defaultAnimation()
            .onTapGesture {
                guard !dismissed else { return }
                model.wasDismissed()
                dismissed = true
            }
        }

        var content: some View {
            VStack(spacing: 0) {
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin * 3)
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
            .background(Color.clear)
        }

        private var baseColor: Color {
            switch model.type {
            case .success: return ColorSemantic.allCool.color
            case .warning: return ColorSemantic.warning.color
            case .error: return ColorSemantic.danger.color
            case .information: return ColorSemantic.warning.color
            }
        }
    }
}

struct AlertModelTestView: View {
    @State var alertModel: Model.AlertModel? = nil
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
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
                    ForEach(Model.AlertModel.AlertType.allCases, id: \.self) { type in
                        Button("\(type)") {
                            alertModel = .init(type: type, message: type.rawValue)
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
