//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

public extension Image {
    func contentMode(_ mode: ContentMode) -> some View {
        resizable().aspectRatio(contentMode: mode)
    }

    func tint(color: Color) -> some View {
        foregroundColor(color)
    }

    func resize(width: CGFloat, height: CGFloat, alignment: Alignment = .center) -> some View {
        resizable().frame(width: width, height: height, alignment: alignment)
    }

    func resize(size: CGSize, alignment: Alignment = .center) -> some View {
        resizable().frame(width: size.width, height: size.height, alignment: alignment)
    }
}

//
// MARK: - systemName
//

// swiftlint:disable no_hardCodedImages
public extension Image {
    static var systemHeart: Image {
        Image(systemName: "heart")
    }

    static var globe: Image {
        Image(systemName: "globe.asia.australia.fill")
    }
}

// swiftlint:enable no_hardCodedImages
