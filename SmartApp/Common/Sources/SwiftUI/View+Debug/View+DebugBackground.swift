//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

public extension View {
    func testListRowBackground() -> some View {
        #if DEBUG
        listRowBackground(Color.random)
        #else
        self
        #endif
    }

    func testBackground() -> some View {
        #if DEBUG
        background(Color.random)
        #else
        self
        #endif
    }

    func testAnimatedBackground() -> some View {
        testAnimatedBackground(.red, .blue)
    }

    func testAnimatedBackgroundRandom() -> some View {
        testAnimatedBackground(.random, .random)
    }

    func testAnimatedBackground(
        _ color1: Color = .red,
        _ color2: Color = .blue
    ) -> some View {
        #if DEBUG
        modifier(AnimatedBackground(color1: color1, color2: color2))
        #else
        self
        #endif
    }
}

public struct AnimatedBackground: ViewModifier {
    @State private var isVisible: Bool
    private let lineWidth: CGFloat = 5
    private let color1: Color
    private let color2: Color
    public init(
        isVisible: Bool = false,

        color1: Color = .red,
        color2: Color = .blue
    ) {
        self.isVisible = isVisible
        self.color1 = color1
        self.color2 = color2
    }

    public func body(content: Content) -> some View {
        content
            .overlay(content: {
                Rectangle()
                    .trim(from: isVisible ? 1 : 0, to: 1)
                    .stroke(color1, lineWidth: lineWidth)
                    .padding(lineWidth)

                Rectangle()
                    .trim(from: isVisible ? 1 : 0, to: 1)
                    .stroke(color2, lineWidth: lineWidth)
                    .rotationEffect(.degrees(180))
            })
            .onAppear(perform: {
                withAnimation(.linear(duration: 1)) {
                    isVisible = true
                }
            })
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
fileprivate extension Common_Preview {
    struct DebugBackgroundTestView: View {
        public init() {}
        public var body: some View {
            VStack {
                Text("testAnimatedBackground").padding().testAnimatedBackground()
                SwiftUIUtils.FixedVerticalSpacer(height: 5)
                Text("testAnimatedBackground").padding().testAnimatedBackground(.blue, .blue)
                SwiftUIUtils.FixedVerticalSpacer(height: 5)
                Text("testAnimatedBackground").padding().testAnimatedBackgroundRandom()
            }
        }
    }
}

#Preview {
    Common_Preview.DebugBackgroundTestView()
}

#endif
