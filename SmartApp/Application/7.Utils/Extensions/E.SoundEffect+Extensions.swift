//
//  SoundEffect.swift
//  Domain
//
//  Created by Ricardo Santos on 23/08/2024.
//

import Foundation
import AVFAudio
//
import DevTools
import Domain

public extension SoundEffect {
    func play() {
        let soundPlayer = SoundPlayer()
        soundPlayer.playSound(self)
    }

    class SoundPlayer {
        var audioPlayer: AVAudioPlayer?
        func playSound(_ sound: SoundEffect) {
            guard sound != .none else { return }
            guard let soundURL = Bundle.main.url(forResource: sound.rawValue, withExtension: nil) else {
                DevTools.Log.error("Sound file not found: \(sound.rawValue)", .generic)
                return
            }
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                DevTools.Log.error(error, .generic)
            }
        }
    }
}
