//
//  Gender.swift
//  SmartApp
//
//  Created by Ricardo Santos on 16/05/2024.
//

import Foundation

public enum Gender: String, CaseIterable, Identifiable, Sendable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    public var id: String { rawValue }
}
