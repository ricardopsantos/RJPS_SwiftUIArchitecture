//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import Foundation
import SwiftUI
import Combine

//
// Simple MVVM with @EnvironmentObject
//

//
// MARK: View
//

public extension SampleCounterDomain {
    struct SampleCounterV1_View: View {
        public typealias ViewModel = SampleCounterDomain.SampleCounter_ViewModel
        @EnvironmentObject private var viewModel: ViewModel
        public var body: some View {
            VStack {
                SwiftUIUtils.RenderedView("\(Self.self).\(#function)")
                SampleCounterShared.displayView(
                    title: "ViewModel with @EnvironmentObject",
                    counterValue: $viewModel.count,
                    onTap: {
                        viewModel.increment()
                    }()
                )
            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
public struct SampleCounterV1_Preview: PreviewProvider {
    static let viewModel = SampleCounterDomain.SampleCounter_ViewModel(
        count: SampleCounterDomain.startValue
    )
    public static var previews: some View {
        SampleCounterDomain.SampleCounterV1_View()
            .environmentObject(viewModel)
    }
}
#endif
