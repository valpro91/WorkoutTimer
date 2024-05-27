//
//  DoWorkoutScreen.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 19/5/24.
//

import SwiftUI
import AVFAudio

struct DoWorkoutScreen: View {
    @StateObject var viewModel: DoWorkoutViewModel
    
    
//    Build an exercise flow
//    - countdownscreen
//    - Set 1
//    - Pause
//    - Set 2
//    ...
//    reward Screen
    
    var body: some View {
        VStack {
            Text(viewModel.workout.name).font(.largeTitle)
            
            List(viewModel.workoutSets) { set in
                Text(set.name)
            }
            
            Text("Current set: \(viewModel.currentSet.name)").font(.title)
            Spacer()
            HStack {
                VStack {
                    Text("Active Time")
                    Picker("Active Time", selection: $viewModel.localActiveTime) {
                        ForEach([15, 30, 45, 60, 75, 90, 120], id: \.self) { time in
                            Text("\(time)").tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 125)
                }
                
                VStack {
                    Text("Pause Time")
                    Picker("Pause Time", selection: $viewModel.localPauseTime) {
                        ForEach([0, 5, 10, 15, 30], id: \.self) { time in
                            Text("\(time)").tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 125)
                }
            }
            
            HStack {
                Text("Rounds")
                Picker("Rounds", selection: $viewModel.localRounds) {
                    ForEach([1, 2, 3, 4, 5], id: \.self) { rounds in
                        Text("\(rounds)").tag(rounds)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
            }
            
            Spacer()
            
            Text(viewModel.isRunning ? "Current Exercise: \(viewModel.currentSet.exercises[viewModel.currentExercise])" : "Next Exercise: \(viewModel.currentSet.exercises[viewModel.currentExercise])").font(.headline)
            Text("Time Remaining").font(.title)
            Text(viewModel.isRunning ? "\(viewModel.timeRemaining)" : "\(viewModel.localActiveTime)").font(.system(size: 80))
            
            HStack {
//                Button(viewModel.isRunning ? "Pause" : "Start") {
//                    viewModel.isRunning ? viewModel.pauseWorkout() : viewModel.startWorkout()
//                }
//                .buttonStyle(.borderedProminent)
//                .padding()
                
                NavigationLink(destination: DoSetView(viewModel: DoSetViewModel(workout: viewModel.workout, workoutSetArray: viewModel.workoutSets))){
                    Text("Start Workout")
                }
                .buttonStyle(.borderedProminent)
                
                Button("Reset") {
                    viewModel.resetWorkout()
                }
                .buttonStyle(.bordered)
                .padding()
            }
        }
        .background(viewModel.isSetActive ? Color(.systemGreen) : Color(.systemBackground))
        .onAppear {
            viewModel.updateLocalTimes()
        }
        .onDisappear {
            viewModel.resetWorkout()
        }
    }
}
