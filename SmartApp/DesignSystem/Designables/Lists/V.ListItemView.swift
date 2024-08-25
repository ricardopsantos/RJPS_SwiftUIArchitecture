import SwiftUI
import Foundation
//
import Common

public struct ListItemView: View {
    @Environment(\.colorScheme) var colorScheme
    private let title: String
    private let subTitle: String
    private let systemImage: (name: String, color: Color)
    private let backgroundColor: Color
    private let cornerRadius: CGFloat
    private let shadowRadius: Double
    private let onTapGesture: (() -> Void)?

    @State private var isPressed: Bool = false

    public init(
        title: String,
        subTitle: String,
        systemImage: (name: String, color: Color) = ("info.circle", ColorSemantic.primary.color),
        backgroundColor: Color = .backgroundTertiary,
        cornerRadius: CGFloat = SizeNames.cornerRadius,
        shadowRadius: Double = 5.0,
        onTapGesture: (() -> Void)? = nil
    ) {
        self.title = title
        self.subTitle = subTitle
        self.systemImage = systemImage
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.onTapGesture = onTapGesture
    }

    public var body: some View {
        HStack {
            titleAndSubTitle
            accessoryImage
        }
        .padding(SizeNames.defaultMarginSmall)
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .shadow(color: backgroundColor.opacity(0.5), radius: shadowRadius)
        .scaleEffect(isPressed ? 0.985 : 1.0)
        .opacity(isPressed ? 0.8 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5), value: isPressed)
        .onTapGesture {
            if let onTapGesture = onTapGesture {
                withAnimation {
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + Common.Constants.defaultAnimationsTime / 2) {
                        isPressed = false
                        onTapGesture()
                    }
                }
            }
        }
    }

    @ViewBuilder
    var titleAndSubTitle: some View {
        if subTitle.isEmpty {
            titleView
        } else {
            VStack(spacing: SizeNames.size_1.cgFloat) {
                titleView
                subTitleView
            }
        }
    }

    var titleView: some View {
        Text(title)
            .fontSemantic(.body)
            .foregroundColor(.labelPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var subTitleView: some View {
        Text(subTitle)
            .fontSemantic(.callout)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.labelSecondary)
            .multilineTextAlignment(.leading)
    }

    // let margin = SizeNames.size_3.cgFloat

    var accessoryImage: some View {
        Group {
            if !systemImage.name.isEmpty {
                ListItemView.buildAccessoryImage(
                    systemImage: systemImage.name,
                    imageColor: systemImage.color,
                    margin: SizeNames.size_3.cgFloat
                )
                /*
                 ZStack {
                     Circle()
                         .foregroundColor(systemImage.color.opacity(0.1))
                         .frame(
                             width: SizeNames.defaultMargin + margin,
                             height: SizeNames.defaultMargin + margin
                         ).overlay(
                             Circle()
                                 .stroke(
                                     systemImage.color.opacity(0.5),
                                     lineWidth: 1
                                 )
                         )
                     Image(systemName: systemImage.name)
                         .resizable()
                         .scaledToFit()
                         .frame(
                             maxWidth: SizeNames.defaultMargin - (margin / 2),
                             maxHeight: SizeNames.defaultMargin - (margin / 2)
                         )
                         .foregroundColor(systemImage.color.opacity(0.75))
                 }*/
            } else {
                EmptyView()
            }
        }
    }
}

//
// MARK: - Auxiliar
//

public extension ListItemView {
    static func buildAccessoryImage(
        systemImage: String,

        imageColor: Color,
        margin: CGFloat
    ) -> some View {
        ZStack {
            Circle()
                .foregroundColor(imageColor.opacity(0.1))
                .frame(
                    width: SizeNames.defaultMargin + margin,
                    height: SizeNames.defaultMargin + margin
                ).overlay(
                    Circle()
                        .stroke(
                            imageColor.opacity(0.5),
                            lineWidth: 1
                        )
                )
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(
                    maxWidth: SizeNames.defaultMargin - (margin / 2),
                    maxHeight: SizeNames.defaultMargin - (margin / 2)
                )
                .foregroundColor(imageColor.opacity(0.75))
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    VStack(spacing: 0) {
        ListItemView(title: "title1", subTitle: "subTitle", systemImage: ("info.circle", .red), onTapGesture: {})
        ListItemView(title: "title2", subTitle: "", systemImage: ("info.circle", .blue), onTapGesture: {})
        ListItemView(title: "title3", subTitle: "", systemImage: ("", .clear), onTapGesture: {})
        Spacer()
    }
}
#endif
