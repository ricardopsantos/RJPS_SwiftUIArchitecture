//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

public extension Common {
    struct ViewOffsetPreferenceKey: PreferenceKey {
        // https://stackoverflow.com/questions/65062590/swiftui-detect-when-scrollview-has-finished-scrolling
        public static var defaultValue = CGFloat.zero
        public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value += nextValue()
        }
    }
}

//
// MARK: - Test/Usage View
//

struct ViewOffsetPreferenceKeyTestView: View {
    let preferenceChangeDetector: CurrentValueSubject<Common.ViewOffsetPreferenceKey.Value, Never>
    let preferenceChangePublisher: AnyPublisher<Common.ViewOffsetPreferenceKey.Value, Never>
    let coordinateSpaceKey = "coordinateSpaceKey"
    @State private var originY: CGFloat = 0
    @State private var text: String = ""

    init() {
        let detector = CurrentValueSubject<CGFloat, Never>(0)
        self.preferenceChangePublisher = detector
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .dropFirst()
            .eraseToAnyPublisher()
        self.preferenceChangeDetector = detector
    }

    public var body: some View {
        ZStack {
            ScrollView {
                ScrollViewReader { scrollView in
                    VStack {
                        Button("Scroll to id_50") { withAnimation { scrollView.scrollTo("id_50", anchor: .center) } }
                        ForEach(0...100, id: \.self) { i in
                            TextField("\(i)", text: $text)
                                .background(Color.clear.id("id_\(i)"))
                        }
                        Button("Scroll to id_50") { withAnimation { scrollView.scrollTo("id_50", anchor: .center) } }
                    }.padding()
                        .background(GeometryReader {
                            Color.clear.preference(
                                key: Common.ViewOffsetPreferenceKey.self,
                                value: -$0.frame(in: .named(coordinateSpaceKey)).origin.y
                            )
                        })
                        .onPreferenceChange(Common.ViewOffsetPreferenceKey.self) {
                            preferenceChangeDetector.send($0)
                        }
                }
            }
            HStack {
                VStack {
                    Text("Ended @ \(Int(originY))")
                    Spacer()
                }
                Spacer()
            }
        }
        .coordinateSpace(name: coordinateSpaceKey)
        .onReceive(preferenceChangePublisher) {
            Common.LogsManager.debug("Stopped on: \($0)")
            originY = $0
        }
    }
}

#Preview {
    ViewOffsetPreferenceKeyTestView()
}
