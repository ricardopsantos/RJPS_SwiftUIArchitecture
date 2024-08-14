//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import Foundation
import SwiftUI
import Combine

// https://paigeshin1991.medium.com/swiftui-how-to-declare-variables-inside-geometryreader-aa5ebade46a8
public extension CommonLearnings {
    struct DeclareVariablesInsideGeometryReader: View {
        public var body: some View {
            VStack {
                bodyV1
                bodyV2WithProxy
            }
        }

        var bodyV1: some View {
            VStack {
                GeometryReader { geometry in
                    let size = geometry.size
                    Text("Hello world")
                        .frame(width: size.width, height: size.height, alignment: .top)
                }
            }
        }

        var bodyV2WithProxy: some View {
            func viewWithProxy(_ proxy: GeometryProxy) -> some View {
                let size = proxy.size
                return Text("Hello world")
                    .frame(width: size.width, height: size.height, alignment: .top)
            }
            return VStack {
                GeometryReader { geometry in
                    viewWithProxy(geometry)
                }
            }
        }

        var bodyV2AsAnyView: some View {
            VStack {
                GeometryReader { proxy -> AnyView in
                    let size = proxy.size
                    return AnyView(
                        Text("Hello world")
                            .frame(width: size.width, height: size.height, alignment: .top)
                    )
                }
            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    CommonLearnings.DeclareVariablesInsideGeometryReader()
}
#endif
