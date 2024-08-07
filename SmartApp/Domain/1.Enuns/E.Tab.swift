//
//  Tab.swift
//  SmartApp
//
//  Created by Ricardo Santos on 19/05/2024.
//

import Foundation
import Common

public enum Tab: String, CaseIterable, Equatable {
    case tab1
    case tab2
    case tab3
    case tab4

    public var title: String {
        rawValue.capitalised
    }

    public var icone: String {
        switch self {
        case .tab1: "1.circle.fill"
        case .tab2: "2.circle.fill"
        case .tab3: "3.circle.fill"
        case .tab4: "4.circle.fill"
        }
    }
}
