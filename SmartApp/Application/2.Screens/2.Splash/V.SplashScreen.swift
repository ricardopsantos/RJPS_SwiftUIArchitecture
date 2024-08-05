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
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .splash,
            navigationViewModel: .disabled,
            background: .clear,
            loadingModel: nil,
            alertModel: nil
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
