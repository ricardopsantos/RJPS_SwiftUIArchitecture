//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

// https://medium.com/@alessandromanilii/swiftui-custom-modifier-84ce498b0112

/**
 In SwiftUI, a `ViewModifier`  is a method that returns a new version of the view it is called on,
 with additional behaviour or appearance. View modifiers are represented by functions that have the
 `modifier` suffix, and they can be chained together to create complex and reusable views.
 */

//
// MARK: - LoaderView
//

public struct LoaderView: View {
    @Environment(\.colorScheme) var colorScheme
    public var isLoading = true
    public var body: some View {
        if isLoading {
            VStack {
                ProgressView()
            }
            .padding()
            .padding()
            .padding()
            .background(.background)
            .cornerRadius(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Color.gray.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
            )
        }
    }
}

public struct LoaderViewModifier: ViewModifier {
    var isLoading: Bool
    public func body(content: Content) -> some View {
        content
            .overlay(LoaderView(isLoading: isLoading))
    }
}

extension View {
    func loading(_ value: Bool) -> some View {
        modifier(LoaderViewModifier(isLoading: value))
    }
}

//
// MARK: - HideNavigationBar
//

public struct HideNavigationBar: ViewModifier {
    // https://newbedev.com/swiftui-hide-tabview-bar-inside-navigationlink-views
    public func body(content: Content) -> some View {
        content.navigationBarTitle("", displayMode: .inline)
    }
}

public extension View {
    func hideNavigationBar() -> some View {
        modifier(HideNavigationBar())
    }
}

//
// MARK: - BorderModifier
//

public extension View {
    func borderModifier(width: CGFloat, color: Color) -> some View {
        modifier(BorderModifier(width: width, color: color))
    }
}

public struct BorderModifier: ViewModifier {
    let width: CGFloat
    let color: Color
    public func body(content: Content) -> some View {
        content.border(color, width: width)
    }
}

//
// MARK: - ShadowModifier
//

struct ShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black, radius: 10)
    }
}

//
// MARK: - ViewFrameGetter
//

// https://izziswift.com/get-width-of-a-view-using-in-swiftui/
struct ViewFrameGetter: ViewModifier {
    @Binding var rects: (CGRect, CGRect)
    public func body(content: Content) -> some View {
        GeometryReader { g -> Color in // (g) -> Content in - is what it could be, but it doesn't work
            DispatchQueue.main.async { // to avoid warning
                rects = (g.frame(in: .local), g.frame(in: .global))
            }
            return Color.clear // return content - doesn't work
        }
    }

    static func sampleUsage() -> any View {
        @State var viewFrame: (CGRect, CGRect) = (.zero, .zero)
        let result2 = Text("").overlay(
            GeometryReader { proxy in
                Color.clear.onAppear {
                    Common.LogsManager.debug("First HEIGHT: \(proxy.size.height)")
                }
            })
        // p rint(viewFrame)
        return result2
    }
}

//
// MARK: - Preview
//

fileprivate extension Common_Preview {
    struct SampleViewsModifiers: View {
        public init() {}
        @State var viewFrame: (CGRect, CGRect) = (.zero, .zero)
        public var body: some View {
            VStack {
                Text("Hello World").modifier(ShadowModifier())
                Divider()
                Text("Hello World").borderModifier(width: 2, color: .black)
                Divider()
            }.onDragDismissKeyboardV1()
        }
    }
}

#if canImport(SwiftUI) && DEBUG
#Preview {
    Common_Preview.SampleViewsModifiers()
        .loading(.false)
}
#endif
