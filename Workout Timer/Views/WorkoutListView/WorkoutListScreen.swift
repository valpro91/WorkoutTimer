//
//  WorkoutListScreen.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 19/5/24.
//

import SwiftUI

struct WorkoutCell: View {
    var workout: Workout
    
    var body: some View {
        HStack{
            Text(workout.name)
                .font(.title)
            Spacer()
            NavigationLink(destination: ShowWorkoutScreen(workout: workout)){
                Text("Show")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct WorkoutListScreen: View {
   
    @StateObject private var viewModel = SetWorkoutViewModel()
    
    
    
    var body: some View {
        NavigationStack{
            VStack{
                Text("Your Workouts")
                    .font(.largeTitle)
                
                List(viewModel.workouts){ workout in
                    WorkoutCell(workout: workout)
                }
                .listStyle(.plain)
                HStack{
                    NavigationLink(destination: SetListScreen()) {
                        Text("Set Library")
                    }
                    .padding()
                    
                    Spacer()
                    
                    NavigationLink(destination: CreateWorkoutScreen()) {  // <-- Move NavigationLink outside
                        Text("Add new Workout")
                    }
                    .padding()
                }
            }
        }
        .onAppear() {
            viewModel.loadData()
        }
    }
}
