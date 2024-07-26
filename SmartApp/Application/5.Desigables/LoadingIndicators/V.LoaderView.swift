//
//  LoaderView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
import DesignSystem

struct LoaderView: View {
    @Environment(\.colorScheme) var colorScheme
    var isLoading = true
    var body: some View {
        if isLoading {
            VStack {
                ProgressView()
            }
            .padding(SizeNames.defaultMarginBig)
            .background(.background)
            .cornerRadius(SizeNames.cornerRadius)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Color.gray.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
            )
        }
    }
}

struct LoaderViewModifier: ViewModifier {
    var isLoading: Bool
    func body(content: Content) -> some View {
        content
            .overlay(LoaderView(isLoading: isLoading))
    }
}

extension View {
    func loader(_ value: Bool) -> some View {
        modifier(LoaderViewModifier(isLoading: value))
    }
}

#Preview {
    Rectangle()
        .loader(true)
}
