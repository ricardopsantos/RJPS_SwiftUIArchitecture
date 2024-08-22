//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

public struct CommonLearnings {
    private init() {}
    public enum VM {}
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    ScrollView {
        VStack {
            SwiftUIUtils.RenderedView("\(#function)")
            CommonLearnings.UseDrawingGroupToSpeedUpView(
                useCompositingGroup: false,
                useDrawingGroup: false
            )
            CommonLearnings.UseDrawingGroupToSpeedUpView(
                useCompositingGroup: true,
                useDrawingGroup: true
            )
            CommonLearnings.NeumorphicButton()
            CommonLearnings.KeyboardPinToTextField()
            CommonLearnings.SolvingRedraw_TimerCountFixedView()
            CommonLearnings.CategoryPickerUsageView()
        }
    }
}
#endif
