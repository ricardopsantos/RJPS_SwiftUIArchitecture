//
//  CardView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 03/01/24.
//

import SwiftUI
import Foundation

public struct ListItemView: View {
    @Environment(\.colorScheme) var colorScheme
    private let title: String
    private let subTitle: String
    private let systemNameImage: String
    private let backgroundColor: Color
    private let cornerRadius: CGFloat
    private let shadowRadius: Double
    private let onTapGesture: () -> Void

    public init(
        title: String,
        subTitle: String,
        systemNameImage: String = "info.circle",
        backgroundColor: Color = .backgroundTertiary,
        cornerRadius: CGFloat = SizeNames.cornerRadius,
        shadowRadius: Double = 5.0,
        onTapGesture: @escaping () -> Void = {}
    ) {
        self.title = title
        self.subTitle = subTitle
        self.systemNameImage = systemNameImage
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
        .shadow(color: backgroundColor.opacity(0.5),
                radius: shadowRadius)
        .onTapGesture {
            onTapGesture()
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
    
    var accessoryImage: some View {
        Group {
            if !systemNameImage.isEmpty {
                Image(systemName: systemNameImage)
                    .resizable()
                    .frame(
                        width: SizeNames.defaultMargin,
                        height: SizeNames.defaultMargin
                    )
                    .foregroundColor(.primaryColor)
            } else {
                EmptyView()
            }
        }
    }
}

#Preview {
    VStack {
        ListItemView(title: "title1",
                     subTitle: "subTitle",
                     systemNameImage:"info.circle", onTapGesture: {})
        ListItemView(title: "title2",
                     subTitle: "",
                     systemNameImage:"info.circle", onTapGesture: {})
        ListItemView(title: "title3",
                     subTitle: "",
                     systemNameImage:"", onTapGesture: {})
        Spacer()
    }
}
