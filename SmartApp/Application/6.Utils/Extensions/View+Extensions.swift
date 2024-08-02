//
//  View+Extensions.swift
//  Core
//
//  Created by Ricardo Santos on 02/08/2024.
//

import SwiftUI
//
import DesignSystem

public extension View {
    func customBackButton(action: @escaping () -> Void, title: String = "") -> some View {
        navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        action()
                    } label: {
                        Image(systemName: "chevron.left")
                            .tint(Color.blue) // Replace with ColorSemantic.primary.color
                    }
                }
                if !title.isEmpty {
                    ToolbarItem(placement: .principal) {
                        Header(text: title)
                    }
                }
            }
    }
}
