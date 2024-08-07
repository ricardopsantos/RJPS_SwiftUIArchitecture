//
//  TypingEffectView.swift
//  Common
//
//  Created by Ricardo Santos on 07/08/2024.
//

import Foundation
import SwiftUI

// https://blog.devgenius.io/swiftui-5-crafting-onboarding-screens-with-animated-transitions-from-scratch-fd25882cf9a5

extension SwiftUITipsAndTricks {
    struct TypingEffectView: View {
        @State private var displayedText = ""
        var fulltext: String
        @State private var currentCharacterIndex: String.Index!

        init(fulltext: String) {
            self.fulltext = fulltext
        }

        var body: some View {
            VStack {
                Text(displayedText)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, maxHeight: 150, alignment: .topLeading)
            }
            .onAppear {
                startTypingEffect()
            }
        }

        func startTypingEffect() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                currentCharacterIndex = fulltext.startIndex
                Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
                    displayedText.append(fulltext[currentCharacterIndex])
                    currentCharacterIndex = fulltext.index(after: currentCharacterIndex)
                    if currentCharacterIndex == fulltext.endIndex {
                        timer.invalidate()
                    }
                }
            }
        }
    }
}

#Preview {
    SwiftUITipsAndTricks.TypingEffectView(fulltext: String.randomWithSpaces(500))
}
