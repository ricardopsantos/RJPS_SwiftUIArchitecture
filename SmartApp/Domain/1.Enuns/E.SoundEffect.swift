//
//  E.SoundEffect.swift
//  Domain
//
//  Created by Ricardo Santos on 23/08/2024.
//

import Foundation

public enum SoundEffect: String, Sendable, CaseIterable {
    case none
    case airHorn = "air-horn-club.caf"
    case amb1 = "amb1.caf"
    case applause1 = "applause1.caf"
    case applause2 = "applause2.caf"
    case bomb1 = "bomb1.caf"
    case boo1 = "boo1.caf"
    case cheer1 = "cheer1.caf"
    case cheer2 = "cheer2.caf"
    case crickets = "crickets.caf"
    case cuek = "cuek.caf"
    case dixie = "dixie.caf"
    case doh = "doh.caf"
    case drama = "drama.caf"
    case haha = "haha.caf"
    case incorrect = "incorrect.caf"
    case lightSaberOn = "lightsaber_on.caf"
    case rimShot = "rimshot.caf"
    case sadTrombone = "sadtrombone.caf"
}

public extension SoundEffect {
    var name: String {
        switch self {
        case .none: return "None"
        case .amb1: return "Ambient"
        case .applause1: return "Clapping"
        case .applause2: return "Cheering"
        case .bomb1: return "Explosion"
        case .boo1: return "Disapproval"
        case .cheer1: return "Encouragement"
        case .cheer2: return "Celebration"
        case .cuek: return "Disinterest"
        case .dixie: return "Nostalgic"
        case .drama: return "Tension"
        case .incorrect: return "Error"
        case .airHorn, .crickets, .doh, .haha, .lightSaberOn, .rimShot, .sadTrombone:
            return rawValue.camelCaseToWords.replace(".caf", with: "")
        }
    }
}
