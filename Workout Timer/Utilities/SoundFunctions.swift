//
//  SoundFunctions.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 22/5/24.
//

import Foundation
import AVFAudio

func playSoundFile(soundURL: URL) {
    do {
        let audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
        audioPlayer.play()
    } catch {
        print("Error playing sound:", error)
    }
}
    
func configureAudioSession()  {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session:", error)
        }
}
    
