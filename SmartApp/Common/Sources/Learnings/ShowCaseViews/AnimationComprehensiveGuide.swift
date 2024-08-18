//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import Foundation
import SwiftUI
import Combine

// https://medium.com/codex/swiftui-animation-a-comprehensive-guide-from-basic-to-advanced-8571a6cd55b5

public extension CommonLearnings {
    struct AnimationComprehensiveGuide {}
}

public extension CommonLearnings.AnimationComprehensiveGuide {
    struct Basic: View {
        let animation: Animation
        let name: String
        public init(_ animation: Animation, _ name: String) {
            self.animation = animation
            self.name = name
        }

        @State private var isAnimated = false
        public var body: some View {
            Button(name) {
                withAnimation(animation) {
                    isAnimated.toggle()
                }}
                .padding()
                .background(isAnimated ? Color.red : Color.green)
        }
    }
}

public extension CommonLearnings.AnimationComprehensiveGuide {
    /// Moving Things Around: X and Y Axis Animation
    struct MovingXY: View {
        @State private var offsetX: CGFloat = 0
        @State private var offsetY: CGFloat = 0

        public var body: some View {
            VStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 50, height: 50)
                    .offset(x: offsetX, y: offsetY) // Use offsetX and offsetY

                HStack {
                    Button("Left") {
                        withAnimation(.spring()) {
                            offsetX -= 50
                        }
                    }

                    Button("Right") {
                        withAnimation(.spring()) {
                            offsetX += 50
                        }
                    }

                    Button("Up") {
                        withAnimation(.spring()) {
                            offsetY -= 50
                        }
                    }

                    Button("Down") {
                        withAnimation(.spring()) {
                            offsetY += 50
                        }
                    }
                }
            }
        }
    }
}

public extension CommonLearnings.AnimationComprehensiveGuide {
    /// Spin Me Right Round: Rotation Animation
    struct Rotate2D: View {
        @State private var angle: Double = 0

        public var body: some View {
            VStack {
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(angle)) // Fixed rotationEffect

                Slider(value: $angle, in: 0...360, step: 1) // Fixed range and spacing

                Button("Spin!") {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        angle += 360
                    }
                }
            }
            .padding() // Added padding for better layout
        }
    }
}

public extension CommonLearnings.AnimationComprehensiveGuide {
    struct Rotate3D: View {
        @State private var degrees: (x: Double, y: Double, z: Double) = (0, 0, 0)

        public var body: some View {
            VStack {
                Text("3D Flip!")
                    .padding()
                    .background(Color.orange)
                    .rotation3DEffect(.degrees(degrees.x), axis: (x: 1, y: 0, z: 0))
                    .rotation3DEffect(.degrees(degrees.y), axis: (x: 0, y: 1, z: 0))
                    .rotation3DEffect(.degrees(degrees.z), axis: (x: 0, y: 0, z: 1))

                VStack {
                    Slider(value: $degrees.x, in: 0...360, step: 1)
                    Text("X-axis: \(Int(degrees.x))°")

                    Slider(value: $degrees.y, in: 0...360, step: 1)
                    Text("Y-axis: \(Int(degrees.y))°")

                    Slider(value: $degrees.z, in: 0...360, step: 1)
                    Text("Z-axis: \(Int(degrees.z))°")

                    Button("Reset") {
                        withAnimation(.spring()) {
                            degrees = (0, 0, 0)
                        }
                    }
                }
                .padding() // Added padding for better layout
            }
        }
    }
}

public extension CommonLearnings.AnimationComprehensiveGuide {
    struct GrowingAndShrinking: View {
        @State private var scale: CGFloat = 1.0

        public var body: some View {
            VStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow) // Fixed foregroundColor syntax
                    .font(.system(size: 50)) // Fixed font syntax
                    .scaleEffect(scale) // Applied scaleEffect

                Slider(value: $scale, in: 0.5...3) // Fixed slider range and syntax

                Button("Pulse") {
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) { // Fixed animation syntax
                        scale = 2.0
                    }
                }
            }
            .padding() // Added padding for better layout
        }
    }
}

public extension CommonLearnings.AnimationComprehensiveGuide {
    struct Teleport: View {
        @State private var position: CGPoint = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)

        public var body: some View {
            GeometryReader { geometry in
                VStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 50, height: 50)
                        .position(position)

                    Button("Teleport") {
                        withAnimation(.spring()) {
                            let randomX = CGFloat.random(in: 0...geometry.size.width)
                            let randomY = CGFloat.random(in: 0...geometry.size.height)
                            position = CGPoint(x: randomX, y: randomY)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all) // Optional: Prevents the Circle from going outside the visible screen
        }
    }
}

public extension CommonLearnings.AnimationComprehensiveGuide {
    struct MorphingShape: Shape {
        var morphProgress: Double

        public func path(in rect: CGRect) -> Path {
            var path = Path()

            if morphProgress < 0.5 {
                // Morph from circle to square
                let circleProgress = 1 - (morphProgress * 2)
                let radius = min(rect.width, rect.height) / 2 * circleProgress
                path.addArc(
                    center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: radius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360),
                    clockwise: false
                )
            } else {
                // Morph from square to circle
                let squareProgress = (morphProgress - 0.5) * 2
                let sideLength = min(rect.width, rect.height)
                let xOffset = (rect.width - sideLength) / 2
                let yOffset = (rect.height - sideLength) / 2
                let cornerRadius = sideLength / 2 * squareProgress
                path.addRoundedRect(
                    in: CGRect(
                        x: xOffset,
                        y: yOffset,
                        width: sideLength,
                        height: sideLength
                    ),
                    cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
                )
            }
            return path
        }
    }

    struct MorphingShapeView: View {
        @State private var morphProgress: Double = 0

        public var body: some View {
            VStack {
                MorphingShape(morphProgress: morphProgress)
                    .fill(Color.blue)
                    .frame(width: 200, height: 200)

                Slider(value: $morphProgress)

                Button("Morph") {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        morphProgress = morphProgress == 0 ? 1 : 0
                    }
                }
            }
            .padding()
        }
    }
}

public extension CommonLearnings.AnimationComprehensiveGuide {
    struct Gesture: View {
        @State private var offset: CGSize = .zero
        @State private var color: Color = .blue

        public var body: some View {
            VStack {
                Circle()
                    .fill(color)
                    .frame(width: 100, height: 100)
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                withAnimation(.spring()) {
                                    offset = gesture.translation
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.spring()) {
                                    offset = .zero
                                    color = Color.random
                                }
                            }
                    )
                Text("Drag the circle!")
                    .padding()
            }
        }
    }
}

public extension CommonLearnings.AnimationComprehensiveGuide {
    struct AnimatedCard: View {
        @State private var isFlipped = false
        @State private var animateFrame = false
        @State private var animateColor = false

        public var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(animateColor ? Color.purple : Color.blue)
                    .frame(width: animateFrame ? 300 : 200, height: animateFrame ? 200 : 300)
                    .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: animateFrame)
                    .animation(.easeInOut(duration: 1.5), value: animateColor)

                if !isFlipped {
                    Text("Tap to Flip")
                        .foregroundColor(.white)
                        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                } else {
                    Text(" ")
                        .font(.system(size: 50))
                        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                }
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
                    isFlipped.toggle()
                    animateFrame.toggle()
                }

                withAnimation(.easeInOut(duration: 1.5).delay(0.5)) {
                    animateColor.toggle()
                }
            }
        }
    }
}

public extension CommonLearnings.AnimationComprehensiveGuide {
    struct PathAnimationView: View {
        @State private var progress: CGFloat = 0

        public var body: some View {
            VStack {
                Text("\(progress)")
                ZStack {
                    // The path
                    Path { path in
                        path.move(to: CGPoint(x: 50, y: 50))
                        path.addCurve(
                            to: CGPoint(x: 300, y: 50),
                            control1: CGPoint(x: 100, y: 200),
                            control2: CGPoint(x: 250, y: -50)
                        )
                    }
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [5]))

                    // The animating circle
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .offset(x: -10, y: -10) // Adjust offset to center the circle on the path
                        .position(position(for: progress))
                }
                .frame(width: 350, height: 250)

                Button("Animate") {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        progress = 1
                    }
                }
            }
        }

        func position(for progress: CGFloat) -> CGPoint {
            let path = Path { path in
                path.move(to: CGPoint(x: 50, y: 50))
                path.addCurve(
                    to: CGPoint(x: 300, y: 50),
                    control1: CGPoint(x: 100, y: 200),
                    control2: CGPoint(x: 250, y: -50)
                )
            }
            return path.trimmedPath(from: 0, to: progress).currentPoint ?? .zero
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview("Basic") {
    VStack {
        CommonLearnings.AnimationComprehensiveGuide.Basic(.linear(duration: 1), "linear")
        CommonLearnings.AnimationComprehensiveGuide.Basic(.easeOut(duration: 1), "easeOut")
        CommonLearnings.AnimationComprehensiveGuide.Basic(.spring, "spring")
    }
}

#Preview("Misc1") {
    VStack {
        Spacer()
        CommonLearnings.AnimationComprehensiveGuide.MovingXY()
        Spacer()
        Divider()
        Spacer()
        CommonLearnings.AnimationComprehensiveGuide.Rotate2D()
        Spacer()
        Divider()
        Spacer()
        CommonLearnings.AnimationComprehensiveGuide.Rotate3D()
        Spacer()
    }
}

#Preview("Misc2") {
    VStack {
        Spacer()
        CommonLearnings.AnimationComprehensiveGuide.GrowingAndShrinking()
        Spacer()
        Divider()
        Spacer()
        CommonLearnings.AnimationComprehensiveGuide.Teleport()
        Spacer()
        Divider()
        Spacer()
        CommonLearnings.AnimationComprehensiveGuide.MorphingShapeView()
        Spacer()
    }
}

#Preview("Misc3") {
    VStack {
        Spacer()
        CommonLearnings.AnimationComprehensiveGuide.Gesture()
        Spacer()
        Divider()
        Spacer()
        CommonLearnings.AnimationComprehensiveGuide.AnimatedCard()
        Spacer()
    }
}

#Preview("Misc4") {
    CommonLearnings.AnimationComprehensiveGuide.PathAnimationView()
}
#endif
