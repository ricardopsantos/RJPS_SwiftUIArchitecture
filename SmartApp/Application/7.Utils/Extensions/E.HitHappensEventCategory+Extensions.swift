//
//  HitHappensEventCategory+Extensions.swift
//  SmartApp
//
//  Created by Ricardo Santos on 22/08/2024.
//

import Foundation
import SwiftUI
//
import Domain

extension HitHappensEventCategory {
    var localized: String {
        switch self {
        case .none: return "None".localizedMissing
        case .health: return "Health".localizedMissing
        case .lifestyle: return "Lifestyle".localizedMissing
        case .professional: return "Professional".localizedMissing
        case .personal: return "Personal".localizedMissing
        case .financial: return "Financial".localizedMissing
        case .cultural: return "Cultural".localizedMissing
        case .entertainment: return "Entertainment".localizedMissing
        case .social: return "Social".localizedMissing
        case .educational: return "Educational".localizedMissing
        case .fitness: return "Fitness".localizedMissing
        }
    }
    
    var systemImageName: String {
          switch self {
          case .none: return "questionmark"
          case .health: return "heart.fill"
          case .lifestyle: return "leaf.fill"
          case .professional: return "briefcase.fill"
          case .personal: return "person.fill"
          case .financial: return "dollarsign.circle.fill"
          case .cultural: return "globe"
          case .entertainment: return "film.fill"
          case .social: return "person.2.fill"
          case .educational: return "book.fill"
          case .fitness: return "figure.walk"
          }
      }
    
    var color: Color {
          switch self {
          case .none: return Color.gray // Neutral color for "None"
          case .health: return Color.red // Color commonly associated with health
          case .lifestyle: return Color.green // Represents natural and balanced lifestyle
          case .professional: return Color.blue // Professional and corporate color
          case .personal: return Color.purple // Represents individuality and personal matters
          case .financial: return Color.orange // Represents financial aspects
          case .cultural: return Color.teal // Color that represents culture and diversity
          case .entertainment: return Color.pink // Bright and engaging color for entertainment
          case .social: return Color.yellow // Color associated with social interactions
          case .educational: return Color.indigo // Represents learning and education
          case .fitness: return Color.green.opacity(0.7) // Slightly different green for fitness and activity
          }
      }
}
