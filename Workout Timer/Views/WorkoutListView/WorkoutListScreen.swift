//
//  WorkoutListScreen.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 19/5/24.
//

import SwiftUI

struct WorkoutListScreen: View {
    
    @State private var workouts: [Workout] = []
    @State private var setLibrary: [Set] = []
        
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack{
            VStack{
                Text("Your Workouts")
                    .font(.largeTitle)
                
                List(workouts){ workout in
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
            loadSets { result in
                switch result {
                case .success(let fetchedSets):
                    setLibrary = fetchedSets
                    print(setLibrary)
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
            
            loadWorkouts { result in
                switch result  {
                case .success(let fetchedWorkouts):
                    workouts = fetchedWorkouts
                    print(workouts)
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
