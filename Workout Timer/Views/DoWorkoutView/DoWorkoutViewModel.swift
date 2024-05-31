////
////  DoWorkoutViewModel.swift
////  Workout Timer
////
////  Created by Valentin Prossliner on 22/5/24.
////
//

import Foundation
import AVFoundation
import AVFAudio
import SwiftUI
import Combine

class DoWorkoutViewModel: ObservableObject {
    @Published var workout: LocalWorkout
    @Published var workoutSets: [Set]
    @Published var currentSet: Set
    @Published var isRunning = false
    @Published var isSetActive = false
    @Published var currentExercise = 0
    @Published var currentRound = 0
    @Published var timeRemaining = 0
    @Published var timeLeft = 0
    @Published var localActiveTime = 0
    @Published var localPauseTime = 0
    @Published var localRounds = 0
    @Published var initCounter = 0
    
    private var audioPlayer: AVAudioPlayer?
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var timer: Timer? = nil
    private var startWorkoutQueueItem: DispatchWorkItem?
    
    init(workout: LocalWorkout, workoutSets: [Set]) {
        self.workout = workout
        self.workoutSets = workoutSets
        self.currentSet = workoutSets.first ?? Set(name: "Default", exercises: [], activeTime: 60, pauseTime: 0)
        updateLocalTimes()
        configureAudioSession()
        initCounter += 1
        print(workout)
        print("Do WorkoutViewModel Initiated \(initCounter)")
        print("retry")
    }
    
    func startWorkout() {
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
            let exerciseName = currentSet.exercises[currentExercise]
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
    
    func pauseWorkout() {
        startWorkoutQueueItem?.cancel()
        isRunning = false
        isSetActive = false
        timeLeft = timeRemaining
        timer?.invalidate()
    }
    
    func resetWorkout() {
        UIApplication.shared.isIdleTimerDisabled = false
        startWorkoutQueueItem?.cancel()
        timer?.invalidate()
        isRunning = false
        isSetActive = false
        currentExercise = 0
        currentSet = workoutSets[0]
        currentRound = 0
        timeRemaining = localActiveTime
    }
    
    func updateLocalTimes() {
        localActiveTime = currentSet.activeTime
        localPauseTime = currentSet.pauseTime
        localRounds = 1
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
                currentExercise += 1
                if currentExercise < currentSet.exercises.count {
                    let nextExercise = currentSet.exercises[currentExercise]
                    speak(text: "Prepare for \(nextExercise)")
                } else {
                    currentExercise = 0
                    currentRound += 1
                    if currentRound >= localRounds {
                        print("Streak +1")
                        playTone("complete")
                        resetWorkout()
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
    
    private func speak(text: String) {
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

