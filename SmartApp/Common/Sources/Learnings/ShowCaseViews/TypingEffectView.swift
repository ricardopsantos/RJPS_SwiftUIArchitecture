//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import Foundation
import SwiftUI
import Combine

// https://blog.devgenius.io/swiftui-5-crafting-onboarding-screens-with-animated-transitions-from-scratch-fd25882cf9a5

extension CommonLearnings {
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

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    CommonLearnings.TypingEffectView(fulltext: String.randomWithSpaces(500))
}
#endif
