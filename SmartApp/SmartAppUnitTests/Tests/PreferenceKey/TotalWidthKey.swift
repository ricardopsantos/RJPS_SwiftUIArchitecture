//
//  TotalWidthKey.swift
//  SmartAppUnitTests
//
//  Created by Ricardo Santos on 07/08/2024.
//

import Foundation
import SwiftUI

//
// MARK: Preferences Key
//

struct TotalWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

//
// MARK: - Example 1
//

struct ChildView: View {
    var body: some View {
        Text("Child View")
            .padding()
            .background(GeometryReader { geometry in
                Color.clear.preference(key: TotalWidthKey.self, value: geometry.size.width)
            })
    }
}

struct ChildViewTwo: View {
    var body: some View {
        Text("Child View Two")
            .padding()
            .background(GeometryReader { geometry in
                Color.clear.preference(key: TotalWidthKey.self, value: geometry.size.width)
            })
    }
}

struct ChildViewThree: View {
    var body: some View {
        Text("Child View Three")
            .padding()
            .background(GeometryReader { geometry in
                Color.clear.preference(key: TotalWidthKey.self, value: geometry.size.width)
            })
    }
}

struct ParentView: View {
    @State var totalWidth: CGFloat = 0

    var body: some View {
        VStack {
            ChildView()
            ChildViewTwo()
            ChildViewThree()
            Text("Total Width: \(totalWidth)")
        }
        .onPreferenceChange(TotalWidthKey.self) { value in
            totalWidth = value
        }
    }
}

#Preview {
    ParentView()
}
