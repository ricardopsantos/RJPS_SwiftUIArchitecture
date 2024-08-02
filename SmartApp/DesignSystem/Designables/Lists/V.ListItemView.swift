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
    private let backgroundColor: Color
    private let cornerRadius: CGFloat
    private let shadowRadius: Double
    private let infoAction: () -> Void

    public init(
        title: String,
        subTitle: String,
        backgroundColor: Color = .backgroundTertiary,
        cornerRadius: CGFloat = SizeNames.cornerRadius,
        shadowRadius: Double = 5.0,
        infoAction: @escaping () -> Void = {}
    ) {
        self.title = title
        self.subTitle = subTitle
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.infoAction = infoAction
    }

    public var body: some View {
        HStack {
            VStack(spacing: SizeNames.defaultMargin) {
                Text(title)
                    .fontSemantic(.body)
                    .foregroundColor(.labelPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(subTitle)
                    .fontSemantic(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.labelSecondary)
                    .multilineTextAlignment(.leading)
            }
            Image(systemName: "info.circle")
                .resizable()
                .frame(
                    width: SizeNames.defaultMargin,
                    height: SizeNames.defaultMargin
                )
                .foregroundColor(.primaryColor)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .shadow(color: Color.gray.opacity(0.5), radius: shadowRadius)
    }
}

#Preview {
    ListItemView(title: "title", subTitle: "subTitle", infoAction: {})
}
