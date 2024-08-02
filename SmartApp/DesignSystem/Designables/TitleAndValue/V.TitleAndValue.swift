//
//  TitleValue.swift
//  SmartApp
//
//  Created by Ricardo Santos on 19/05/2024.
//

import Foundation
import SwiftUI

public struct TitleAndValueView: View {
    public enum Style: CaseIterable {
        case horizontal
        case vertical1
        case vertical2
    }

    @Environment(\.colorScheme) var colorScheme
    private let title: String
    private let value: String
    private let style: Style
    public init(title: String, value: String, style: Style = .horizontal) {
        self.title = title
        self.value = value
        self.style = style
    }

    public var body: some View {
        Group {
            switch style {
            case .horizontal:
                HStack(spacing: 0) {
                    titleView
                    Spacer()
                    valueView
                }
            case .vertical1:
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        titleView
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        Spacer()
                        valueView
                    }
                }
            case .vertical2:
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0, content: {
                        titleView
                        valueView
                    })
                    Spacer()
                }
            }
        }
    }

    var titleView: some View {
        Text(title)
            .fontSemantic(.bodyBold)
            .foregroundColorSemantic(.labelPrimary)
    }

    var valueView: some View {
        Text(value)
            .fontSemantic(.body)
            .foregroundColorSemantic(.labelSecondary)
    }
}

#Preview {
    VStack {
        Spacer()
        ForEach(TitleAndValueView.Style.allCases, id: \.self) { style in
            TitleAndValueView(title: "title", value: "\(style)", style: style)
            Divider()
        }
        Spacer()
    }
}
