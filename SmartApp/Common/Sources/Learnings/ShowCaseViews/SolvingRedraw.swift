//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import Foundation
import SwiftUI
import Combine

public extension CommonLearnings {
    //
    // MARK: -  Solving redraw issues in SwiftUI
    // https://www.avanderlee.com/swiftui/debugging-swiftui-views/
    //

    struct SolvingRedraw_TimerCountFixedView: View {
        @State var count = 0
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        public var body: some View {
            VStack {
                Text("Count is now: \(count)!")
                    .onReceive(timer) { _ in
                        count += 1
                    }
                CommonLearnings.SolvingRedraw_AnimatedButton()
            }
        }
    }

    struct SolvingRedraw_AnimatedButton: View {
        @State var animateButton = true
        public var body: some View {
            Button {} label: {
                Text("SAVE")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 80)
                    .background(Color.red)
                    .cornerRadius(50)
                    .shadow(color: .secondary, radius: 1, x: 0, y: 5)
            }.rotationEffect(Angle(degrees: animateButton ? Double.random(in: -8.0...1.5) : Double.random(in: 0.5...16))).onAppear {
                withAnimation(.easeInOut(duration: 1).delay(0.5).repeatForever(autoreverses: true)) {
                    animateButton.toggle()
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
    CommonLearnings.SolvingRedraw_TimerCountFixedView()
}
#endif
