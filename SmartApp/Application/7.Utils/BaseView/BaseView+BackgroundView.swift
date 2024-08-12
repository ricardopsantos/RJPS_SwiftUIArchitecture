//
//  BackgroundView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 03/08/2024.
//

import Foundation
import SwiftUI
//
import DesignSystem

extension BaseView.BackgroundView {
    enum Background {
        case clear
        case linear
        case gradient
        static var defaultBackground: Self {
            .linear
        }
    }
}

extension BaseView {
    struct BackgroundView: View {
        private let background: Background
        public init(background: Background) {
            self.background = background
        }

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
    HStack(spacing: 0) {
        BaseView.BackgroundView(background: .clear)
        Divider()
        BaseView.BackgroundView(background: .linear)
        Divider()
        BaseView.BackgroundView(background: .gradient)
    }.background(Color.random)
}
