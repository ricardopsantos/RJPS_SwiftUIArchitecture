//
//  AppSizes.swift
//  SmartApp
//
//  Created by Ricardo Santos on 16/05/2024.
//

import Foundation

//
// MARK: - SizesNamesButton
//

public enum SizeNames: Int, Codable, CaseIterable {
    case size_0 = 0
    case size_1 = 2 // Preferred
    case size_2 = 4
    case size_3 = 8 // Unit
    case size_4 = 16 // Base
    case size_5 = 24
    case size_6 = 32 // Preferred
    case size_7 = 40
    case size_8 = 48
    case size_9 = 56
    case size_10 = 64 // Preferred
}

public extension SizeNames {
    static var cornerRadius: CGFloat { 10 }
    static var defaultMarginSmall: CGFloat { defaultMargin / 2 }
    static var defaultMargin: CGFloat { size_5.cgFloat }
    static var defaultMarginBig: CGFloat { defaultMargin * 2 }
    static var defaultButtonPrimaryHeight: CGFloat { SizesNamesButton.primary.size.height }
    static var defaultButtonSecondaryDefaultHeight: CGFloat { SizesNamesButton.secondary.size.height }
    static var defaultButtonTertiaryDefaultHeight: CGFloat { SizesNamesButton.tertiary.size.height }

    static var defaultBarButtonSize: CGSize { CGSize(
        width: SizeNames.size_3.cgFloat,
        height: SizeNames.size_3.cgFloat
    ) }

    var intValue: Int {
        Int(rawValue)
    }

    var cgFloat: CGFloat {
        CGFloat(rawValue)
    }
}

//
// MARK: - SizesNamesButton
//

public enum SizesNamesButton: Int, Codable, CaseIterable {
    case primary = 1
    case secondary
    case tertiary

    public var size: CGSize {
        switch self {
        case .primary: return primarySize
        case .secondary: return secondarySize
        case .tertiary: return tertiarySize
        }
    }

    enum CodingKeys: String, CodingKey {
        case primary
        case secondary
        case tertiary
    }

    public var width: CGFloat {
        size.width
    }

    public var height: CGFloat {
        size.height
    }

    private var ratioChange: CGFloat {
        0.75
    }

    private var primarySize: CGSize {
        let primarySizeValue: CGFloat = SizeNames.size_9.cgFloat
        return CGSize(
            width: primarySizeValue,
            height: 44
        )
    }

    private var secondarySize: CGSize {
        CGSize(
            width: (primarySize.width * ratioChange) * 1,
            height: (primarySize.height * ratioChange) * 1
        )
    }

    private var tertiarySize: CGSize {
        CGSize(
            width: (primarySize.width * ratioChange) * ratioChange,
            height: (primarySize.height * ratioChange) * ratioChange
        )
    }
}
