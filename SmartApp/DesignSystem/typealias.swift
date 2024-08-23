//
//  typealias.swift
//  DesignSystem
//
//  Created by Ricardo Santos on 23/08/2024.
//

import Foundation

public typealias TextStyleTuple = (font: FontSemantic, color: ColorSemantic?)
func == (lhs: TextStyleTuple, rhs: TextStyleTuple) -> Bool {
    // swiftlint:disable random_rule_2
    lhs.font == rhs.font && lhs.color == rhs.color
    // swiftlint:enable random_rule_2
}
