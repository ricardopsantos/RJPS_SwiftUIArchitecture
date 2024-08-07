//
//  AppImages.swift
//  DesignSystem
//
//  Created by Ricardo Santos on 04/08/2024.
//

import Foundation
import SwiftUI

public enum AppImages: String, CaseIterable {
    case arrowBackward
    case close
    case checkMark
    case square

    var image: Image {
        switch self {
        case .arrowBackward: Image(systemName: "arrow.backward")
        case .close: Image(systemName: "xmark")
        case .checkMark: Image(systemName: "checkmark.square")
        case .square: Image(systemName: "square")
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    VStack(spacing: 0) {
        ForEach(AppImages.allCases, id: \.self) { item in
            HStack {
                Text(item.rawValue)
                Spacer()
                item.image
            }
        }
        Spacer()
    }.frame(maxWidth: UIScreen.screenWidth / 2)
}
#endif
