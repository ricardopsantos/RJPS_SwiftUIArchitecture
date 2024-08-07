//
//  Colors.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
import Common

public extension View {
    func backgroundColorSemantic(_ value: ColorSemantic) -> some View {
        background(value.color)
    }

    func foregroundColorSemantic(_ value: ColorSemantic) -> some View {
        foregroundColor(value.color)
    }
}

public extension Color {
    static var dangerColor: Color { ColorSemantic.danger.color }
    static var warningColor: Color { ColorSemantic.warning.color }
    static var allCoolColor: Color { ColorSemantic.allCool.color }
    static var primaryColor: Color { ColorSemantic.primary.color }

    static var labelPrimary: Color { ColorSemantic.labelPrimary.color }
    static var labelSecondary: Color { ColorSemantic.labelSecondary.color }
    static var labelPrimaryInverted: Color { ColorSemantic.labelPrimaryInverted.color }
    static var labelSecondaryInverted: Color { ColorSemantic.labelSecondaryInverted.color }

    static var systemPrimary: Color { ColorSemantic.systemPrimary.color }
    static var systemSecondary: Color { ColorSemantic.systemSecondary.color }

    static var backgroundPrimary: Color { ColorSemantic.backgroundPrimary.color }
    static var backgroundSecondary: Color { ColorSemantic.backgroundSecondary.color }
    static var backgroundTertiary: Color { ColorSemantic.backgroundTertiary.color }
    static var backgroundGradient: Color { ColorSemantic.backgroundGradient.color }
}

// https://www.youtube.com/watch?v=zfFZ99MBEPk&ab_channel=ChristopherDeane

public indirect enum ColorSemantic: CaseIterable, Hashable {
    case color(_ colorSemantic: ColorSemantic, alpha: CGFloat)

    case clear // Static Color!
    case danger // Static Color!
    case warning // Static Color!
    case allCool // Static Color!
    case primary // Static Color!

    case labelPrimary
    case labelSecondary
    case labelPrimaryInverted
    case labelSecondaryInverted

    case systemPrimary
    case systemSecondary

    case backgroundPrimary // Regular screens background
    case backgroundSecondary
    case backgroundTertiary
    case backgroundGradient // Regular background shadows

    public static var allCases: [ColorSemantic] = [
        .clear,
        .danger,
        .warning,
        .allCool,
        .primary,

        .labelPrimary,
        .labelSecondary,
        .labelPrimaryInverted,
        .labelSecondaryInverted,

        .systemPrimary,
        .systemSecondary,

        .backgroundPrimary,
        .backgroundSecondary,
        .backgroundTertiary,
        .backgroundGradient
    ]

    //
    // Public
    //

    private static var userCustomInterfaceStyle: Common.InterfaceStyle?
    public static func applyUserCustomInterfaceStyle(_ value: Common.InterfaceStyle?) {
        Self.userCustomInterfaceStyle = value
    }

    var currentInterfaceStyle: Common.InterfaceStyle {
        if let userCustomInterfaceStyle = Self.userCustomInterfaceStyle {
            return userCustomInterfaceStyle
        } else {
            return Common.InterfaceStyle.current
        }
    }

    public var rawValue: UIColor { rawValue(currentInterfaceStyle) }
    public var cgColor: CGColor { rawValue.cgColor }
    public var uiColor: UIColor { rawValue }
    public var color: Color { Color(rawValue) }
    public func color(_ on: Common.InterfaceStyle) -> Color { Color(rawValue(on)) }
    public func uiColor(_ on: Common.InterfaceStyle) -> UIColor { rawValue(on) }
    public var uiColorAlternative: UIColor! { rawValue(currentInterfaceStyle == .dark ? .light : .dark) }
    public var name: String { "\(self)" }

    public init?(rawValue: UIColor) {
        if let some = Self.allCases.first(where: { $0.rawValue == rawValue }) {
            self = some
        } else {
            return nil
        }
    }

    //
    // Utils
    //

    // swiftlint:disable cyclomatic_complexity
    public func rawValue(_ on: Common.InterfaceStyle) -> UIColor {
        let on = on

        var result: UIColor?
        switch self {
        case .color(let color, alpha: let alpha): result = color.uiColor.alpha(alpha)
        case .clear: result = UIColor.clear
        case .danger: result = ColorPalletSmart.red2.uiColor
        case .allCool: result = ColorPalletSmart.green2.uiColor
        case .warning: result = ColorPalletSmart.yellow.uiColor

        case .primary: result = ColorPalletSmart.primary.uiColor

        case .labelPrimary: result = on == .light ?
            ColorPalletSmart.black.uiColor :
            ColorPalletSmart.white.uiColor
        case .labelPrimaryInverted: result = on == .light ?
            ColorPalletSmart.white.uiColor :
            ColorPalletSmart.black.uiColor

        case .labelSecondary: result = on == .light ?
            ColorPalletSmart.black.colorFaded06 :
            ColorPalletSmart.white.colorFaded06
        case .labelSecondaryInverted: result = on == .light ?
            ColorPalletSmart.white.colorFaded06 :
            ColorPalletSmart.black.colorFaded06

        case .systemPrimary: result = on == .light ?
            ColorPalletSmart.systemPrimary.colorFaded02 :
            ColorPalletSmart.systemPrimary.colorFaded02
        case .systemSecondary: result = on == .light ?
            ColorPalletSmart.systemPrimary.colorFaded016 :
            ColorPalletSmart.systemPrimary.colorFaded016

        case .backgroundPrimary: result = on == .light ?
            ColorPalletSmart.white.uiColor :
            ColorPalletSmart.black.uiColor

        case .backgroundSecondary: result = on == .light ?
            ColorPalletSmart.grey2.uiColor :
            ColorPalletSmart.black.uiColor

        case .backgroundTertiary: result = on == .light ?
            UIColor.colorFromRGBString("201,208,214") :
            UIColor.colorFromRGBString("0,0,0")

        case .backgroundGradient: result = on == .light ?
            UIColor.colorFromRGBString("201,208,214") :
            ColorPalletSmart.grey2.uiColor
        }

        return result ?? .clear
    }
    // swiftlint:enable cyclomatic_complexity
}

//
// MARK: - ColorPallet
//
enum ColorPalletSmart: CaseIterable {
    //
    // Cases
    //

    case primary
    case systemPrimary

    case white
    case black
    case silver1
    case silver2

    case grey1
    case grey2

    case green1
    case green2
    case blue
    case blue2
    case red1
    case red2
    case orange
    case yellow

    //
    // Private / Auxiliary
    //

    //
    // Public
    //

    public static var interfaceStyle: Common.InterfaceStyle = .light

    public var name: String { "\(self)" }

    public var colorAlternative: UIColor? { nil }

    public var uiColor: UIColor { rawValue }
    public var color: Color { Color(uiColor) }

    public var colorFaded08: UIColor { uiColor.alpha(0.8) }
    public var colorFaded064: UIColor { uiColor.alpha(0.64) }
    public var colorFaded06: UIColor { uiColor.alpha(0.6) }
    public var colorFaded048: UIColor { uiColor.alpha(0.48) }
    public var colorFaded04: UIColor { uiColor.alpha(0.4) }
    public var colorFaded036: UIColor { uiColor.alpha(0.36) }
    public var colorFaded032: UIColor { uiColor.alpha(0.32) }
    public var colorFaded03: UIColor { uiColor.alpha(0.3) }
    public var colorFaded024: UIColor { uiColor.alpha(0.24) }
    public var colorFaded02: UIColor { uiColor.alpha(0.2) }
    public var colorFaded018: UIColor { uiColor.alpha(0.18) }
    public var colorFaded016: UIColor { uiColor.alpha(0.16) }
    public var colorFaded012: UIColor { uiColor.alpha(0.12) }
    public var colorFaded008: UIColor { uiColor.alpha(0.08) }

    public var colorSwiftUI: SwiftUI.Color { Color(rawValue) }

    public init?(rawValue: UIColor) {
        if let some = Self.allCases.first(where: { $0.rawValue == rawValue }) {
            self = some
        } else {
            return nil
        }
    }

    public var rawValue: UIColor {
        switch self {
        case .primary: return UIColor.colorFromRGBString("98,157,228") // #629DE4(Twitter Blue)
        case .white: return UIColor.colorFromRGBString("255,255,255") // #FFFFFF
        case .black: return UIColor.colorFromRGBString("20,20,19") // #141413
        case .grey1: return UIColor.colorFromRGBString("89,89,89") // #595959
        case .grey2: return UIColor.colorFromRGBString("48,50,51") // #303233
        case .silver1: return UIColor.colorFromRGBString("150,157,163") // #969DA3
        case .silver2: return UIColor.colorFromRGBString("240,241,242") // #F0F1F2
        case .green1: return UIColor.colorFromRGBString("172,239,183") // #ACE6B7
        case .green2: return UIColor.colorFromRGBString("50,215,75") // #32D74B
        case .blue: return UIColor.colorFromRGBString("125,207,227") // #7DCFE3
        case .blue2: return UIColor.colorFromRGBString("10,132,255") // #0A84FF
        case .red1: return UIColor.colorFromRGBString("230,156,152") // #E69C98
        case .red2: return UIColor.colorFromRGBString("230,64,64") // #E64040
        case .orange: return UIColor.colorFromRGBString("246,190,49") // #F6BE31
        case .yellow: return UIColor.colorFromRGBString("255,204,0") // #FFCC00

        case .systemPrimary: return UIColor.colorFromRGBString("120,124,128") // #787880
        }
    }
}

//
// MARK: - ColorsCache
//

private struct ColorsCache {
    private init() {}
    public static let shared = ColorsCache()
    @PWThreadSafe private var _cache = NSCache<NSString, AnyObject>()
    public func add(object: AnyObject, withKey: String) {
        // objc_sync_enter(cache); defer { objc_sync_exit(cache) }
        _cache.setObject(object as AnyObject, forKey: withKey as NSString)
    }

    public func get(key: String) -> AnyObject? {
        // objc_sync_enter(cache); defer { objc_sync_exit(_cache) }
        if let object = _cache.object(forKey: key as NSString) {
            return object
        }
        return nil
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    HStack {
        VStack(spacing: 1) {
            ForEach(ColorSemantic.allCases.filter { $0 != .clear }, id: \.self) { style in
                Text("\(style)")
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                SwiftUIUtils.FixedVerticalSpacer(height: 5)
            }
        }
        VStack(spacing: 1) {
            ForEach(ColorSemantic.allCases.filter { $0 != .clear }, id: \.self) { style in
                Text("\(style)")
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .background(style.color(.light))
                SwiftUIUtils.FixedVerticalSpacer(height: 5)
            }
        }
        VStack(spacing: 1) {
            ForEach(ColorSemantic.allCases.filter { $0 != .clear }, id: \.self) { style in
                Text("\(style)")
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .background(style.color(.dark))
                SwiftUIUtils.FixedVerticalSpacer(height: 5)
            }
        }
    }
}
#endif
