//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import Foundation
import SwiftUI
import Combine

//
// MARK: - NeumorphicButton
// https://medium.com/devtechie/neumorphic-button-in-ios-16-and-swiftui-75360b41866e
//

public extension CommonLearnings {
    struct NeumorphicButton: View {
        let offWhiteColor = Color(red: 236 / 255, green: 234 / 255, blue: 235 / 255)
        let shadowColor = Color(red: 197 / 255, green: 197 / 255, blue: 197 / 255)
        public var body: some View {
            let shape1 = Circle()
            // let shape2 = RoundedRectangle(cornerRadius: 20, style: .continuous)
            if #available(iOS 16.0, *) {
                return ZStack {
                    VStack {
                        Text("NeumorphicButton")
                            .font(.caption)
                        Button(action: {}) {
                            Image.globe
                                .resizable()
                                .frame(width: 40, height: 40)
                                .padding(25)
                                .foregroundColor(Color.orange)
                                .background(
                                    shape1
                                        .fill(
                                            // .shadow(.inner(color: shadowColor,radius: 3, x: 3, y: 3))
                                            // .shadow(.inner(color: .white, radius: 3, x: -3, y: -3))
                                            .shadow(.drop(color: shadowColor, radius: 3, x: 3, y: 3))
                                                .shadow(.drop(color: .white, radius: 3, x: -3, y: -3))
                                        )
                                        .foregroundColor(offWhiteColor)
                                )
                        }
                    }
                }
            } else {
                return Text("Not iOS16")
            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    CommonLearnings.NeumorphicButton()
}
#endif
