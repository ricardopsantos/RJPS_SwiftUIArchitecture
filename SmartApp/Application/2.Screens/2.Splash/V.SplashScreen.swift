//
//  SplashScreen.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
import Common
import DesignSystem

struct SplashView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        BaseView.with(
            sender: "\(Self.self)",
            appScreen: .splash,
            navigationViewEmbed: false,
            scrollViewEmbed: false,
            ignoresSafeArea: false,
            background: .clear
        ) {
            content
        }
    }

    var content: some View {
        ZStack {
            ColorSemantic.primary.color.ignoresSafeArea(.all)
            VStack {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth * 0.33)
                    .cornerRadius(SizeNames.cornerRadius)
            }
            .padding()
        }
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension SplashView {}

//
// MARK: - Private
//
fileprivate extension SplashView {}

#Preview {
    SplashView()
}
