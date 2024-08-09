//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

public extension View {
    
    func testListRowBackground() -> some View {
        #if DEBUG
        self.listRowBackground(Color.random)
        #else
        self
        #endif
    }
    
    func testBackground() -> some View {
        #if DEBUG
        self.background(Color.random)
        #else
        self
        #endif
    }
    
    func testAnimatedBackground() -> some View {
        #if DEBUG
        self.modifier(AnimatedBackground())
        #else
        self
        #endif
    }
}

public struct AnimatedBackground: ViewModifier {
    @State private var isVisible: Bool
    private let lineWidth: CGFloat = 5
    public init(isVisible: Bool = false) {
        self.isVisible = isVisible
    }
    public func body(content: Content) -> some View {
        content
            .overlay(content: {
                Rectangle()
                    .trim(from: isVisible ? 1 : 0, to: 1)
                    .stroke(Color.red, lineWidth: lineWidth)
                    .padding(lineWidth)
                 
                Rectangle()
                    .trim(from: isVisible ? 1 : 0, to: 1)
                    .stroke(Color.blue, lineWidth: lineWidth)
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
                Text("View 1")
                    .testAnimatedBackground()
                debugPrint("123")
                debugPrintOnReload(id: "id")
                debugPrintOnReload(ifCondition: true, id: "id")
            }//
        }
    }
}

#Preview {
    Common_Preview.DebugBackgroundTestView()
}

#endif
