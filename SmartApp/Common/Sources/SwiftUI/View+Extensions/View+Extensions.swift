//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

//
// MARK: - View (Animation)
//

public extension View {
    func customBackButton(action: @escaping () -> Void) -> some View {
        navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        action()
                    } label: {
                        Image(systemName: "arrow.backward")
                            .tint(.secondary)
                    }
                }
            }
    }

    @inlinable func easeInOutAnimation() -> some View {
        animation(
            .easeInOut(duration: Common.Constants.defaultAnimationsTime)
                .repeatForever(autoreverses: false),
            value: 1.5
        )
    }

    @inlinable func springAnimation() -> some View {
        animation(
            .spring,
            value: 1.5
        )
    }

    @inlinable func linearAnimation() -> some View {
        animation(
            .linear(duration: Common.Constants.defaultAnimationsTime),
            value: 1.5
        )
    }

    @inlinable func defaultAnimation() -> some View {
        animation(
            .linear(duration: Common.Constants.defaultAnimationsTime),
            value: 1.5
        )
    }
}

//
// MARK: - View (Padding)
//

public extension View {
    // A view that pads this view using the specified edge insets with specified amount of padding.
    func paddingLeft(_ value: CGFloat) -> some View { padding(.leading, value) }
    func paddingRight(_ value: CGFloat) -> some View { padding(.trailing, value) }
    func paddingBottom(_ value: CGFloat) -> some View { padding(.bottom, value) }
    func paddingTop(_ value: CGFloat) -> some View { padding(.top, value) }
}

//
// MARK: - View (Frame)
//
public extension View {
    @ViewBuilder
    func frame(_ length: CGFloat) -> some View {
        frame(width: length, height: length)
    }
}

//
// MARK: - View (Corner utils)
//

public extension View {
    func addCorner(
        color: Color,

        lineWidth: CGFloat,
        padding: Bool
    ) -> some View {
        doIf(padding) { $0.padding(8) }
            .overlay(
                Capsule()
                    .stroke(color, lineWidth: lineWidth)
                    .foregroundColor(Color.clear)
            )
    }

    /// Usage `.cornerRadius1(24, corners: [.topLeft, .topRight])`
    func cornerRadius1(
        _ radius: CGFloat,

        corners: UIRectCorner = .allCorners
    ) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    func cornerRadius2(_ radius: CGFloat) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    func cornerRadius3(_ radius: CGFloat) -> some View {
        cornerRadius(radius)
    }

    func cornerRadius4(_ radius: CGFloat, _ color: Color) -> some View {
        cornerRadius(radius - 1) // Inner corner radius
            .padding(1) // Width of the border
            .background(color) // Color of the border
            .cornerRadius(radius) // Outer corner radius
    }

    func cornerRadius5(
        _ radius: CGFloat,

        corners: UIRectCorner = .allCorners
    ) -> some View {
        clipShape(
            RoundedCorner(radius: radius, corners: corners)
        )
    }
}

public extension View {
    // https://medium.com/better-programming/swiftui-tips-and-tricks-c7840d8eb01b
    var embedInNavigation: some View {
        NavigationView { self }
    }

    var erased: AnyView {
        AnyView(self)
    }

    var erasedToAnyView: AnyView {
        AnyView(self)
    }

    func userInteractionEnabled(_ value: Bool) -> some View {
        disabled(!value)
    }

    func rotate(degrees: Double) -> some View {
        rotationEffect(.degrees(degrees))
    }

    func alpha(_ some: Double) -> some View {
        opacity(some)
    }
}

public extension View {
    /// Usage `Circle().maskContent(using: AngularGradient(gradient: colors, center: .center, startAngle: .degrees(0), endAngle: .degrees(360)))`
    func maskContent(using: some View) -> some View {
        /** In SwiftUI, a view mask is a way to specify which parts of a view should be visible and which should be hidden.
          View masks are created using the mask(_:) modifier, which takes a View as its parameter. The mask view defines
         the shape that will be used to mask the view to which the modifier is applied.
         ```
          Image("my-image").mask(Circle())
          Image("my-image").mask(Text("Hello, World!").font(.largeTitle).foregroundColor(.white))
          ```
          */
        using.mask(self)
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
fileprivate extension Common_Preview {
    struct SampleViewsExtensions: View {
        public init() {}
        public var body: some View {
            EmptyView()
        }
    }
}

#Preview {
    Common_Preview.SampleViewsExtensions()
}

#endif
