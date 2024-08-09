//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    
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

struct AnimatedBackground: ViewModifier {
    
    @State private var isVisible: Bool = false
    let linewidth: CGFloat = 5
    
    func body(content: Content) -> some View {
        content
            .overlay(content: {
                
                Rectangle()
                    .trim(from: isVisible ? 1 : 0, to: 1)
                    .stroke(Color.red, lineWidth: linewidth)
                    .padding(linewidth)
                 
                Rectangle()
                    .trim(from: isVisible ? 1 : 0, to: 1)
                    .stroke(Color.blue, lineWidth: linewidth)
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
                debugPrint("123")
                debugPrintOnReload(id: "id")
                debugPrintOnReload(ifCondition: true, id: "id")
            }.testAnimatedBackground()
        }
    }
}

#Preview {
    Common_Preview.DebugBackgroundTestView()
}

#endif
