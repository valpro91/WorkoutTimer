//
//  ShowWorkoutScreen.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 19/5/24.
//

import SwiftUI

struct SectionHeaderTitle: View {
    var title: String
    var subtitle: String

       var body: some View {
           HStack{
               VStack(alignment: .leading){
                   Text("\(title) Exercises:")
                       .foregroundStyle(.primary)
               }
           }
       }
}


// Add Workout Overview At the top
// calculating Number of sets and total time (incl pause times)
// future describing body parts used 

struct ShowWorkoutScreen: View {
    @StateObject private var viewModel: WorkoutViewModel
    @State private var isExpanded = true
        
    init(workout: Workout) {
        _viewModel = StateObject(wrappedValue: WorkoutViewModel(workout: workout))
    }
    
    
    var StartWorkoutButton: some View {
        NavigationLink(destination:
                        DoSetView(viewModel: DoSetViewModel(workout: LocalWorkout(name: viewModel.workout.name, sets: viewModel.workoutSetRoundsDict, rounds: viewModel.workout.rounds), workoutSetArray: viewModel.workoutSetArray))){
            HStack{
                Text("Start Workout")
                Image(systemName: "play.fill")
            }
        }
    }
    
    func SetRoundsPicker(set: Set) -> some View {
           Picker("Rounds:", selection: Binding(
               get: { viewModel.workoutSetRoundsDict[set] ?? 1 },
               set: { newValue in viewModel.workoutSetRoundsDict[set] = newValue })) {
               ForEach(1..<7) { rounds in
                   Text("\(rounds)").tag(rounds)
               }
           }
       }

       func SetTimeSettings(set: Set) -> some View {
           VStack(alignment: .leading) {
               Text("\(set.name)")
                   .font(.title)
               Picker("Rounds:", selection: Binding(
                get: { viewModel.workoutSetRoundsDict[set] ?? 1 },
                set: { newValue in viewModel.workoutSetRoundsDict[set] = newValue })) {
                    ForEach(1..<7) { rounds in
                        Text("\(rounds)").tag(rounds)
                    }
                }
               HStack {
                   Picker("Active Time:", selection: Binding(
                    get: { set.activeTime },
                    set: { newValue in
                        var updatedSet = set
                        updatedSet.activeTime = newValue
                        viewModel.updateSet(updatedSet)
                    })) {
                        ForEach([15, 30, 45, 60, 75, 90], id: \.self) { activeTime in
                            Text("\(activeTime)").tag(activeTime)
                        }
                    }
                   
                   Picker("Pause Time:", selection: Binding(
                    get: { set.pauseTime },
                    set: { newValue in
                        var updatedSet = set
                        updatedSet.pauseTime = newValue
                        viewModel.updateSet(updatedSet)
                    })) {
                        ForEach([0, 10, 15, 20, 30], id: \.self) { pauseTime in
                            Text("\(pauseTime)").tag(pauseTime)
                            }
                    }
           }
       }
   }
    
    var body: some View {
        NavigationStack {
            VStack {
                List{
                    ForEach(viewModel.workoutSetArray){set in
                        SetTimeSettings(set: set)
//                        SetRoundsPicker(set: set)
//                        SetTimeSettings(set: set)
                        Section(isExpanded: $isExpanded, content:{
                            ForEach(set.exercises, id: \.self){ exercise in
                                Text(exercise)
                            }},
                                header:{ SectionHeaderTitle(title: "\(set.name)", subtitle: "\(set.activeTime) sec on, \(set.pauseTime) sec pause")
                        })

//                        SetRoundsPicker(set: set)
//                        SetTimeSettings(set: set)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(viewModel.workout.name)
        .navigationBarItems(trailing: StartWorkoutButton)
        .onAppear {
            viewModel.loadData()
        }
    }
}


