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
        public let date: Date
        var counter: Int {
            renderedViewCounter[name] ?? 1
        }

        public init(_ name: String, date: Date = Date()) {
            if let renderedViewCounterValue = renderedViewCounter[name] {
                renderedViewCounter[name] = renderedViewCounterValue + 1
            } else {
                renderedViewCounter[name] = 1
            }
            self.name = name
            self.date = date
        }

        public var body: some View {
            // let message = "Redraw[\(counter)]: \(name)"
            Text("Redraw[\(counter)]: \(name)")
                .padding(3)
                .background(Color.random.opacity(0.15))
                .font(.caption2)
                .opacity(0.25)
                .onAppear {
                    // Common.LogsManager.debug(message)
                }
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
private extension Common_Preview {
    struct SwiftUIUtilsPreview: View {
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

struct Common_Previews_SwiftUIUtils: PreviewProvider {
    public static var previews: some View {
        Common_Preview.SwiftUIUtilsPreview().buildPreviews()
    }
}
#endif
