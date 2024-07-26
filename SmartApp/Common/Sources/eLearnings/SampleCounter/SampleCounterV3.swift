//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import Foundation
import SwiftUI
import Combine

//
// Simple MVVM with @StateObject + Protocols
//

//
// https://medium.com/@azalazar/using-viewmodel-protocols-in-swiftui-7f8818342af1
//

public extension SampleCounterDomain {
    final class SampleCounterV3_ViewModel: SampleCounterV3_ViewModelProtocol {
        @Published public var count: Int
        public init(count: Int) {
            self.count = count
        }

        public func increment() {
            count += 1
        }
    }
}

//
// MARK: View
//

public extension SampleCounterDomain {
    struct SampleCounterV3_View<ViewModel>: View where ViewModel: SampleCounterV3_ViewModelProtocol {
        @StateObject private var viewModel: ViewModel
        public init(viewModel: @autoclosure @escaping () -> ViewModel) {
            self._viewModel = StateObject(wrappedValue: viewModel())
        }

        public var body: some View {
            VStack {
                SwiftUIUtils.RenderedView("Main View")
                SampleCounterShared.displayView(
                    title: "ViewModel with @StateObjec + Protocols",
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
public struct SampleCounterV3_Preview: PreviewProvider {
    static let viewModel = SampleCounterDomain.SampleCounterV3_ViewModel(count: SampleCounterDomain.startValue)
    public static var previews: some View {
        SampleCounterDomain.SampleCounterV3_View(
            viewModel: viewModel
        )
    }
}
#endif
