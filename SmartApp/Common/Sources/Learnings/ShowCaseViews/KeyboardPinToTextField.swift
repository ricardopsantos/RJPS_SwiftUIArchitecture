//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import Foundation
import SwiftUI
import Combine

//
// MARK: - KeyboardPinToTextField
//

public extension CommonLearnings {
    struct KeyboardPinToTextField: View {
        //
        // https://twitter.com/natpanferova/status/1590676836488732678?s=46&t=H-9UOSADwiL21W9-VZj76A
        // If we need to permanently pin a view to the bottom of the screen in SwiftUI,
        // we can place it inside safeAreaInset(edge: .bottom) modifier.
        // If we use this method with a text field, it will also automatically
        // move to the top of the keyboard when focused.
        @State private var messages: [(id: Int, text: String)] = [(1, "Message 1"), (2, "Message 2")]
        @State private var newMessageText: String = ""
        public var body: some View {
            List(messages, id: \.0) { item in
                Text(item.1).safeAreaInset(edge: .bottom) { TextField("New message", text: $newMessageText)
                    padding()
                        .textFieldStyle(.roundedBorder)
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
    CommonLearnings.KeyboardPinToTextField()
}
#endif
