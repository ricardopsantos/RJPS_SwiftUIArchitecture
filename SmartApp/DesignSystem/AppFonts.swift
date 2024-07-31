//
//  Fonts.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
import Common

public extension View {
    func fontSemantic(_ value: FontSemantic) -> some View {
        font(value.font)
    }
}

public enum FontsName: CaseIterable {
    case regular
    case medium
    case semibold
    case bold
    var name: String {
        switch self {
        case .regular: "NotoSans-Regular"
        case .bold: "NotoSans-Bold"
        case .medium: "NotoSans-Medium"
        case .semibold: "NotoSans-SemiBold"
        }
    }

    var registerFileName: String {
        name + ".ttf"
    }

    public static func setup() {
        let bundleIdentifier = Bundle(for: BundleFinder.self).bundleIdentifier!
        FontsName.allCases.forEach { font in
            UIFont.registerFontWithFilenameString(font.registerFileName, bundleIdentifier)
        }
    }
}

public extension Font {
    static var largeTitle: Font { FontSemantic.largeTitle.rawValue }
    static var title1: Font { FontSemantic.title1.rawValue }
    static var title2: Font { FontSemantic.title2.rawValue }
    static var headline: Font { FontSemantic.headline.rawValue }
    static var body: Font { FontSemantic.body.rawValue }
    static var bodyBold: Font { FontSemantic.bodyBold.rawValue }
    static var callout: Font { FontSemantic.callout.rawValue }
    static var calloutBold: Font { FontSemantic.calloutBold.rawValue }
    static var footnote: Font { FontSemantic.footnote.rawValue }
    static var caption: Font { FontSemantic.caption.rawValue }
}

public enum FontSemantic: CaseIterable {
    case largeTitle

    case title1
    case title2

    case headline

    case body, bodyBold
    case callout, calloutBold
    case footnote
    case caption

    public var font: Font {
        rawValue
    }

    public var rawValue: Font {
        let trait = UIView().traitCollection.preferredContentSizeCategory
        var multiplier: CGFloat = 1
        if Common_Utils.false {
            // Disabled for now
            let incSize: CGFloat = 0.15
            switch trait {
            case .unspecified: multiplier = 1
            case .extraSmall: multiplier = 1
            case .small: multiplier = 1
            case .accessibilityMedium, .medium: multiplier = 1
            case .accessibilityLarge, .large: multiplier = 1 + (incSize * 1)
            case .accessibilityExtraLarge, .extraLarge: multiplier = 1 + (incSize * 2)
            case .accessibilityExtraExtraLarge, .extraExtraExtraLarge: multiplier = 1 + (incSize * 3)
            case .accessibilityExtraExtraExtraLarge: multiplier = 1 + (incSize * 3)
            default:
                if "\(trait)".contains("UICTContentSizeCategoryXXL") {
                    multiplier = 1 + (incSize * 3)
                } else {
                    multiplier = 1
                }
            }

            Common_Utils.executeOnce(token: "\(Self.self)_\(#function)") {
                Common.LogsManager.debug("TextSizeCategory: \(trait) -> \(multiplier)")
            }
        }

        let bodyFontSize: CGFloat = 15
        return switch self {
        case .largeTitle: Font.custom(FontsName.regular.name, size: bodyFontSize * 2.5)
        case .title1: Font.custom(FontsName.bold.name, size: bodyFontSize * 2)
        case .title2: Font.custom(FontsName.regular.name, size: bodyFontSize * 1.6)
        case .headline: Font.custom(FontsName.regular.name, size: bodyFontSize * 1.2)
        case .body: Font.custom(FontsName.regular.name, size: bodyFontSize)
        case .bodyBold: Font.custom(FontsName.bold.name, size: bodyFontSize)
        case .callout: Font.custom(FontsName.regular.name, size: bodyFontSize * 0.9)
        case .calloutBold: Font.custom(FontsName.regular.name, size: bodyFontSize * 0.8)
        case .footnote: Font.custom(FontsName.regular.name, size: bodyFontSize * 0.7)
        case .caption: Font.custom(FontsName.regular.name, size: bodyFontSize * 0.6)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        ForEach(FontSemantic.allCases, id: \.self) { font in
            Text("\(font)")
                .fontSemantic(font)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
            SwiftUIUtils.FixedVerticalSpacer(height: 5)
        }
    }
}
