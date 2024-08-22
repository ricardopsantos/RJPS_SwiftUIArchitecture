//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

private var renderedViewCounter: [String: Int] = [:]

public enum SwiftUIUtils {
    //
    // MARK: - VisualEffectView
    //

    public struct VisualEffectView: UIViewRepresentable {
        public var effect: UIVisualEffect?
        public init(effect: UIVisualEffect?) {
            self.effect = effect
        }

        public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
        public func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
    }

    //
    // MARK: - RenderedView
    //

    public struct RenderedView: View {
        @Environment(\.colorScheme) var colorScheme
        public let name: String
        public let id: String
        public let date: Date
        var identifier: String {
            if !id.trim.isEmpty {
                return id
            } else {
                return name
            }
        }
        
        var counter: Int {
            renderedViewCounter[identifier] ?? 1
        }

        public init(_ name: String, date: Date = Date(), id customId: String = "") {
            self.id = customId
            self.name = name
            self.date = date
            if let renderedViewCounterValue = renderedViewCounter[identifier] {
                renderedViewCounter[identifier] = renderedViewCounterValue + 1
            } else {
                renderedViewCounter[identifier] = 1
            }
        }

        public var body: some View {
            Text("Redraw[\(counter)]: \(name) | \(identifier.sha1.prefix(10))")
                .padding(3)
                .background(Color.red.opacity(0.25))
                .font(.caption2)
                .opacity(0.25)
                .debugBordersDefault()
        }
    }

    //
    // MARK: - View (Spacer utils)
    //

    public struct VerticalDivider: View {
        @Environment(\.colorScheme) var colorScheme
        public let width: CGFloat
        public init(width: CGFloat = 1) {
            self.width = width
        }

        public var body: some View {
            VStack(spacing: 0) {
                Spacer()
                    .frame(width: width)
                    .background(Color.gray)
            }
        }
    }

    public struct FixedVerticalSpacer: View {
        @Environment(\.colorScheme) var colorScheme
        public let height: CGFloat
        public init(height: CGFloat) {
            self.height = height
        }

        public var body: some View {
            Rectangle()
                .fill(Color.clear)
                .background(Color.clear, alignment: .center)
                .frame(width: 1, height: height)
        }
    }

    public struct FixedHorizontalSpacer: View {
        @Environment(\.colorScheme) var colorScheme
        public let width: CGFloat
        public init(width: CGFloat) {
            self.width = width
        }

        public var body: some View {
            Rectangle()
                .fill(Color.clear)
                .background(Color.clear, alignment: .center)
                .frame(width: width, height: 1)
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
fileprivate extension Common_Preview {
    struct SwiftUIUtilsTestView: View {
        public init() {}
        public var body: some View {
            ZStack {
                SwiftUIUtils.VisualEffectView(effect: UIBlurEffect(style: .extraLight))
                VStack {
                    SwiftUIUtils.RenderedView("\(Self.self)")
                    SwiftUIUtils.FixedHorizontalSpacer(width: 50).background(Color.red)
                    SwiftUIUtils.FixedVerticalSpacer(height: 50).background(Color.green)
                    Spacer()
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    Common_Preview.SwiftUIUtilsTestView()
}

#endif
