//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

/**
 In SwiftUI, `PreferenceKey` is a protocol that allows you to define
 and collect data from views during the layout phase, and then use that data to modify the behaviour of other views.
 */

public struct ViewOffsetPreferenceKey: PreferenceKey {
    // https://stackoverflow.com/questions/65062590/swiftui-detect-when-scrollview-has-finished-scrolling
    public typealias Value = CGFloat
    public static var defaultValue = CGFloat.zero
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
struct ViewOffsetPreferenceKeySampleView: View {
    let preferenceChangeDetector: CurrentValueSubject<ViewOffsetPreferenceKey.Value, Never>
    let preferenceChangePublisher: AnyPublisher<ViewOffsetPreferenceKey.Value, Never>
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
                                key: ViewOffsetPreferenceKey.self,
                                value: -$0.frame(in: .named(coordinateSpaceKey)).origin.y
                            )
                        })
                        .onPreferenceChange(ViewOffsetPreferenceKey.self) {
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

public struct Common_Previews_ViewOffsetPreferenceKey: PreviewProvider {
    public static var previews: some View {
        ViewOffsetPreferenceKeySampleView().buildPreviews()
    }
}
#endif
