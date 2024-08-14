//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import Foundation
import SwiftUI
import Combine

// https://benlmyers.medium.com/9-swiftui-hacks-for-beautiful-views-cd9682fbe2ec

public extension CommonLearnings {
    struct UseDrawingGroupToSpeedUpView: View {
        let useCompositingGroup: Bool
        let useDrawingGroup: Bool

        public var body: some View {
            content1
                .doIf(useDrawingGroup, transform: {
                    $0.drawingGroup()
                })
        }

        var content1: some View {
            VStack {
                ZStack {
                    Text("DrawingGroup")
                        .foregroundColor(.black)
                        .padding(20)
                        .background(Color.red)
                    Text("DrawingGroup")
                        .blur(radius: 2)
                }
                .font(.title)
                .doIf(useCompositingGroup, transform: {
                    $0.compositingGroup()
                })
                .opacity(1.0)
            }
            .background(Color.white)
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    VStack {
        CommonLearnings.UseDrawingGroupToSpeedUpView(
            useCompositingGroup: false,
            useDrawingGroup: false
        )
        CommonLearnings.UseDrawingGroupToSpeedUpView(
            useCompositingGroup: true,
            useDrawingGroup: true
        )
    }
}
#endif
