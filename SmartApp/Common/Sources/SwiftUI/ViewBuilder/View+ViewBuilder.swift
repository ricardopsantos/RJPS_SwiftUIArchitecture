//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

/**
 In SwiftUI, the @ViewBuilder attribute is used to indicate that a function or initializer returns one or more views
 that should be automatically embedded in a parent view.
 */

@ViewBuilder
func makeTextViews() -> some View {
    Text("Hello")
    Text("World")
}

@ViewBuilder
func makeTextViews(texts: [String]) -> some View {
    ForEach(texts, id: \.self) { text in
        Text(text)
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
fileprivate extension Common_Preview {
    struct SampleViewsBuilders: View {
        public init() {}
        @State var viewFrame: (CGRect, CGRect) = (.zero, .zero)
        public var body: some View {
            VStack {
                makeTextViews()
                Divider()
                makeTextViews(texts: ["Hello", "World"])
            }
        }
    }
}

#Preview {
    Common_Preview.SampleViewsBuilders()
}
#endif
