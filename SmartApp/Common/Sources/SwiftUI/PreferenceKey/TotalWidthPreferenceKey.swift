//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

//
// MARK: Preferences Key
//

public extension Common {
    struct TotalWidthPreferenceKey: PreferenceKey {
        public static var defaultValue: CGFloat = 0
        public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value += nextValue()
        }
    }
}

//
// MARK: - Test/Usage View
//

struct ChildView: View {
    var body: some View {
        Text("Child 1")
            .padding()
            .background(GeometryReader { geometry in
                Color.red.preference(key: Common.TotalWidthPreferenceKey.self, value: geometry.size.width)
            })
    }
}

struct ChildViewTwo: View {
    var body: some View {
        Text("Child View Tw2o")
            .padding()
            .background(GeometryReader { geometry in
                Color.blue.preference(key: Common.TotalWidthPreferenceKey.self, value: geometry.size.width)
            })
    }
}

struct ChildViewThree: View {
    @State var width: CGFloat = 100
    var body: some View {
        VStack {
            Button("Inc width") {
                width += 5
            }
            Text("Child View 3")
                .padding()
                .frame(width: width)
                .background(GeometryReader { geometry in
                    Color.green.preference(key: Common.TotalWidthPreferenceKey.self, value: geometry.size.width)
                })
        }
    }
}

struct TotalWidthPreferenceKeyTestView: View {
    @State var totalWidth: CGFloat = 0
    var body: some View {
        VStack {
            ChildView()
            Divider()
            ChildViewTwo()
            Divider()
            ChildViewThree()
            Text("Total Width: \(totalWidth)")
        }
        .onPreferenceChange(Common.TotalWidthPreferenceKey.self) { value in
            Common.LogsManager.debug("\(Common.TotalWidthPreferenceKey.self): \(value)")
            totalWidth = value
        }
    }
}

#Preview {
    TotalWidthPreferenceKeyTestView()
}
