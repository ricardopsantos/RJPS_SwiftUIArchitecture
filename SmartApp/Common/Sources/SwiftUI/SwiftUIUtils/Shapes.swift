//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

//
// https://betterprogramming.pub/an-easy-way-to-create-complex-shapes-for-using-with-swiftui-2a374685ba84
// https://www.hackingwithswift.com/books/ios-swiftui/paths-vs-shapes-in-swiftui
//

/*
 The key to understanding the difference between Path and Shape is reusability:
 paths are designed to do one specific thing, whereas shapes have the flexibility
 of drawing space and can also accept parameters to let us customize them further.
 */

//
// MARK: - Strokes
//

public extension SwiftUI.Shape {
    func strokeSimple(color: UIColor, width: CGFloat) -> some View {
        stroke(Color(color), lineWidth: width)
    }
}

public extension SwiftUI.RoundedRectangle {
    func strokeDashed(color: UIColor, width: CGFloat, dashSize: CGFloat = 10) -> some View {
        strokeBorder(style: StrokeStyle(lineWidth: width, dash: [dashSize]))
            .foregroundColor(Color(color))
    }
}

//
// MARK: - Custom shapes
//

public struct Arc: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool
    public init(startAngle: Angle, endAngle: Angle, clockwise: Bool) {
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.clockwise = clockwise
    }

    public func path(in rect: CGRect) -> Path {
        let rotationAdjustment = Angle.degrees(90)
        let modifiedStart = startAngle - rotationAdjustment
        let modifiedEnd = endAngle - rotationAdjustment
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)
        return path
    }
}

public struct RoundedCorner: Shape {
    public var radius: CGFloat = .infinity
    public var corners: UIRectCorner = .allCorners
    public init(radius: CGFloat = .infinity, corners: UIRectCorner = .allCorners) {
        self.radius = radius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

public struct RoundedCornerWithBorder: Shape {
    public var radius: CGFloat = .infinity
    public var corners: UIRectCorner = .allCorners
    public init(radius: CGFloat = .infinity, corners: UIRectCorner = .allCorners) {
        self.radius = radius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()

        let mainPath = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        path.addPath(Path(mainPath.cgPath))

        let borderRect = CGRect(
            x: rect.origin.x + 1,
            y: rect.origin.y + 1,
            width: rect.size.width - 2,
            height: rect.size.height - 2
        )
        let borderPath = UIBezierPath(
            roundedRect: borderRect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        path.addPath(Path(borderPath.cgPath))
        return path
            .strokedPath(StrokeStyle(lineWidth: 2, lineJoin: .round))
    }
}

public struct Triangle: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}

public struct Hexagon: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let x = rect.midX
        let y = rect.midY
        let side = min(width, height) / 2.0
        let a = side / 2.0
        let b = side / 2.0
        path.move(to: CGPoint(x: x, y: y - side))
        path.addLine(to: CGPoint(x: x + a, y: y - b))
        path.addLine(to: CGPoint(x: x + a, y: y + b))
        path.addLine(to: CGPoint(x: x, y: y + side))
        path.addLine(to: CGPoint(x: x - a, y: y + b))
        path.addLine(to: CGPoint(x: x - a, y: y - b))
        path.closeSubpath()
        return path
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
private extension Common_Preview {
    struct SwiftUIShapes: View {
        public init() {}
        @State var viewFrame: (CGRect, CGRect) = (.zero, .zero)
        let size: CGFloat = 100

        var systemShapes: some View {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.blue)
                        .frame(width: size, height: size / 2)
                    Text("Rectangle").font(.caption2)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.blue)
                        .frame(width: size, height: size / 2)
                    Text("RoundedRectangle").font(.caption2)
                }
                ZStack {
                    Capsule()
                        .fill(.blue)
                        .frame(width: size * 1, height: size * 0.5)
                    Text("Capsule").font(.caption2)
                }
                ZStack {
                    Ellipse()
                        .fill(.blue)
                        .frame(width: size, height: size * 0.5)
                    Text("Ellipse").font(.caption2)
                }
                ZStack {
                    Circle()
                        .fill(.blue)
                        .frame(width: size, height: size)
                    Text("Circle").font(.caption2)
                }
            }
        }

        var customShapes: some View {
            VStack {
                ZStack {
                    HStack {
                        Arc(startAngle: .degrees(0), endAngle: .degrees(90), clockwise: true)
                            .fill(.green)
                            .frame(width: size, height: size)
                        Arc(startAngle: .degrees(0), endAngle: .degrees(180), clockwise: true)
                            .fill(.green)
                            .frame(width: size, height: size)
                        Arc(startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)
                            .fill(.green)
                            .frame(width: size, height: size)
                    }
                    Text("Arc").font(.caption2)
                }
                ZStack {
                    Triangle()
                        .fill(.green)
                        .frame(width: size, height: size)
                    Text("Triangle").font(.caption2)
                }
                ZStack {
                    Hexagon()
                        .fill(.green)
                        .frame(width: size, height: size)
                    Text("Hexagon").font(.caption2)
                }
                HStack {
                    ZStack {
                        VStack {
                            RoundedCorner()
                                .fill(.green)
                                .frame(width: size * 0.5, height: size)
                            RoundedCorner()
                                .fill(.green)
                                .frame(width: size, height: size * 0.5)
                        }
                        Text("RoundedCorner").font(.caption2)
                    }
                    ZStack {
                        VStack {
                            RoundedCornerWithBorder()
                                .fill(.green)
                                .frame(width: size * 0.5, height: size)
                            RoundedCornerWithBorder()
                                .fill(.green)
                                .frame(width: size, height: size * 0.5)
                        }
                        Text("RoundedCornerWithBorder").font(.caption2)
                    }
                }
            }
        }

        public var body: some View {
            ScrollView {
                VStack {
                    customShapes
                    Divider()
                    systemShapes
                }
            }
        }
    }
}
#Preview {
    Common_Preview.SwiftUIShapes()
}

#endif
