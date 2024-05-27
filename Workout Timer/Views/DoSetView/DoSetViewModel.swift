
//
//  DoSetViewModel.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 23/5/24.
//

import Foundation
import AVFAudio
import AVFoundation
import Combine
import UIKit

// special case 0 pause time how to handle that
// fine tune speaking with egge cases - last exercise, how many rounds (workout & Set) etc.

class DoSetViewModel: ObservableObject {
    
    @Published var workout: LocalWorkout
    @Published var setCounter: Int
    @Published var exerciseCounter: Int
    @Published var setArray: [Set]
    
    @Published var isRunning = false
    @Published var isSetActive = false
    
    @Published var currentRound = 0
    @Published var timeRemaining = 0
    @Published var timeLeft = 0
    @Published var localActiveTime = 0
    @Published var localPauseTime = 0
    @Published var localRounds = 0
    @Published var countDownTime = 5
    
    @Published var showCountDownOverlay = true
    
    private var audioPlayer: AVAudioPlayer?
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var timer: Timer? = nil
    private var countDownTimer: Timer? = nil
    private var startWorkoutQueueItem: DispatchWorkItem?
    private var hideCountdownSheet: DispatchWorkItem?
    
    init(workout: LocalWorkout, workoutSetArray: [Set]) {
        self.workout = workout
        self.setCounter = 0
        self.exerciseCounter = 0
        self.setArray = workoutSetArray
        updateLocalTimes()
        configureAudioSession()
    }
    
    func startSet() {
        UIApplication.shared.isIdleTimerDisabled = true
        isRunning = true
        isSetActive = true
        
        startWorkoutQueueItem = DispatchWorkItem {
            self.playTone("start")
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.handleTimerTick()
            }
        }
        
       
        
        if timeLeft == 0 {
            let exerciseName = setArray[setCounter].exercises[exerciseCounter]
            speak(text: "Starting \(exerciseName)")
            timeRemaining = localActiveTime
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: startWorkoutQueueItem!)
        } else {
            timeRemaining = timeLeft
            timeLeft = 0
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.handleTimerTick()
            }
        }
    }
    
    func startCountDownTimer() {
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.handleCoundDownTick()
        }
    }
    
    func handleCoundDownTick() {
        if countDownTime > 0 {
            countDownTime -= 1
        } else {
            showCountDownOverlay = false
            return
        }
        
    }
    
    func pauseSet() {
        startWorkoutQueueItem?.cancel()
        isRunning = false
        isSetActive = false
        timeLeft = timeRemaining
        timer?.invalidate()
    }
    
    func updateLocalTimes() {
        localActiveTime = setArray[setCounter].activeTime
        localPauseTime = setArray[setCounter].pauseTime
        localRounds = workout.sets[setArray[setCounter]] ?? 1
    }
    
    private func handleTimerTick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            speakCountdown(for: timeRemaining, isActivePhase: isSetActive)
        } else {
            if isSetActive {
                isSetActive = false
                timeRemaining = localPauseTime
                playTone("end")
                exerciseCounter += 1
                if exerciseCounter < setArray[setCounter].exercises.count {
                    let nextExercise = setArray[setCounter].exercises[exerciseCounter]
                    speak(text: "Prepare for \(nextExercise)")
                } else {
                    exerciseCounter = 0
                    currentRound += 1
                    if currentRound >= localRounds {
                        playTone("complete")
                        nextSet()
                        return
                    }
                }
            } else {
                isSetActive = true
                timeRemaining = localActiveTime
                playTone("start")
            }
        }
    }
    
    func nextSet() {
        setCounter += 1
        updateLocalTimes()
    }

    
    private func playTone(_ soundType: String) {
        let soundFiles: [String: String] = [
            "start": "start.mp3",
            "end": "pause.mp3",
            "complete": "complete.mp3"
        ]
        
        guard let soundFile = soundFiles[soundType] else {
            print("Invalid sound type: \(soundType)")
            return
        }
        
        guard let soundURL = Bundle.main.url(forResource: soundFile, withExtension: nil) else {
            print("Sound file not found: \(soundFile)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
            print("Playing sound: \(soundFile)")
        } catch {
            print("Error playing sound \(soundFile):", error)
        }
    }
    
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            print("Audio session configured successfully.")
        } catch {
            print("Error setting up audio session:", error)
        }
    }
    
    private func speakCountdown(for seconds: Int, isActivePhase: Bool) {
        let messages = isActivePhase ? [10: "10 Seconds left",
                                        5: "5",
                                        3: "3",
                                        2: "2",
                                        1: "1"] : [5: "5",
                                                    3: "3",
                                                    2: "2",
                                                    1: "1"]
        
        if let message = messages[seconds] {
            speak(text: message)
        }
    }
}
