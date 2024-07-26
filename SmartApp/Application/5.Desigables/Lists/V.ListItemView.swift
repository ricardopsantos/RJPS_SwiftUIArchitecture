//
//  CardView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 03/01/24.
//

import SwiftUI
import Foundation
import DesignSystem

struct ListItemView: View {
    @Environment(\.colorScheme) var colorScheme
    var title = "Title"
    var subTitle = "SubTitle"
    var backgroundColor: Color = .backgroundTertiary
    var cornerRadius = SizeNames.cornerRadius
    var shadowRadius = 5.0
    var infoAction: () -> Void = {}

    var body: some View {
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
    ListItemView(infoAction: {})
}
