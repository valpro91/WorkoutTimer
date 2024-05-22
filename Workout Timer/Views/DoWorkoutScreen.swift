//
//  DoWorkoutScreen.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 19/5/24.
//

import SwiftUI
import AVFoundation
import AVFAudio
import UIKit // Required for UIApplication.shared


struct DoWorkoutScreen: View {
    @State var workout: LocalWorkout
    @State var workoutSets: [Set]
    @State var currentSet: Set
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var timer: Timer? = nil
    @State private var isRunning = false
    @State private var isSetActive = false
    
    
    @State private var currentExercise = 0
    @State private var currentRound = 0
    @State private var timeRemaining = 0
    @State private var timeLeft = 0
    
    @State private var localActiveTime = 0
    @State private var localPauseTime = 0
    @State private var localRounds = 0
    
    @State private var startWorkoutQueueItem: DispatchWorkItem?

    
    func startWorkout() {
        UIApplication.shared.isIdleTimerDisabled = true // Prevent sleep mode
        isRunning = true
        isSetActive = true
        
        // Announce the first exercise
        
        
        startWorkoutQueueItem = DispatchWorkItem {
                   playTone("start")
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
                handleTimerTick()
            }
            
        }
    }
    
    func speakCountdown(for seconds: Int, isActivePhase: Bool) {
        let messages = isActivePhase ? [10:"10 Seconds left",
                                        5: "5",
                                        3: "3",
                                        2: "2",
                                        1: "1"]:[5: "5",
                                                 3: "3",
                                                 2: "2",
                                                 1: "1"]
        
          if let message = messages[seconds] {
              speak(text: message)
          }
      }
    
    func handleTimerTick() {
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
                        playTone("complete")
                        resetWorkout() // Reset once complete
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
    
    func playTone(_ soundType: String) {
        let soundFiles: [String: String] = [
            "start": "start.mp3",
            "end": "pause.mp3",
            "complete": "complete.mp3"
        ]
        
        if let soundFile = soundFiles[soundType],
           let soundURL = Bundle.main.url(forResource: soundFile, withExtension: nil) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Error playing sound:", error)
            }
        }
    }

    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }

    func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session:", error)
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
        UIApplication.shared.isIdleTimerDisabled = false // Prevent sleep mode

        startWorkoutQueueItem?.cancel()
        timer?.invalidate()
        isRunning = false
        isSetActive = false
        currentExercise = 0
        currentSet = workoutSets[0]
        currentRound = 0
        timeRemaining = localActiveTime
    }
    
    func defaultTimes() {
        updateLocalTimes()
    }
    
    func updateLocalTimes() {
        localActiveTime = currentSet.activeTime
        localPauseTime = currentSet.pauseTime
        localRounds = 1
    }
    
    
    var body: some View {
        VStack {
            Text(workout.name).font(.largeTitle)
            
            List(workoutSets) { set in
                Text(set.name)
            }
            
            Text("Current set: \(currentSet.name)").font(.title)
            Spacer()
            HStack {
                VStack{
                    Text("Active Time")
                    Picker("Active Time", selection: $localActiveTime) {
                        ForEach([15,30,45,60,75,90,120], id: \.self) { time in
                            Text("\(time)").tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 125)
                }
                
                VStack{
                    Text("Pause Time")
                    Picker("Pause Time", selection: $localPauseTime){
                        ForEach([0,5,10,15,30], id: \.self) { time in
                            Text("\(time)").tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 125)
                }
               
            }

            HStack {
                Text("Rounds")
                Picker("Rounds", selection: $localRounds){
                    ForEach([1,2,3,4,5], id: \.self) { rounds in
                        Text("\(rounds)").tag(rounds)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
            }
            
            Spacer()
            
            Text(isRunning ? "Current Exercise: \(currentSet.exercises[currentExercise])" :"Next Exercise: \(currentSet.exercises[currentExercise])").font(.headline)
            Text("Time Remaining").font(.title)
            Text(isRunning ? "\(timeRemaining)" : "\(localActiveTime)").font(.system(size: 80))
            
            HStack {
                Button(isRunning ? "Pause" : "Start") {
                    isRunning ? pauseWorkout() : startWorkout()
                }
                .buttonStyle(.borderedProminent)
                .padding()
                
                Button("Reset") {
                    resetWorkout()
                }
                .buttonStyle(.bordered)
                .padding()
            }
        }
        .background(isSetActive ? Color(.systemGreen) : Color(.systemBackground))
        .onAppear {
            configureAudioSession() // Call the function when the view appears
            updateLocalTimes()
                }
        .onDisappear {
                resetWorkout()
                }
        
    }
}
