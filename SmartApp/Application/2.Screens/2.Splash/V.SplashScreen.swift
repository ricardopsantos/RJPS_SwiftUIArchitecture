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

    static let timeToDisplay: Double = 2
    // MARK: - Usage Attributes
    @State private var animatedGradient = true
    @State private var logoOpacity: Double = 1
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .splash,
            navigationViewModel: .disabled,
            background: .clear,
            loadingModel: nil,
            alertModel: nil,
            networkStatus: nil
        ) {
            content
                .onAppear(perform: {
                    withAnimation(.linear(duration: SplashView.timeToDisplay / 2).delay(SplashView.timeToDisplay / 2)) {
                        logoOpacity = 0
                    }
                })
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
                    .opacity(logoOpacity)
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

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    SplashView()
}
#endif
