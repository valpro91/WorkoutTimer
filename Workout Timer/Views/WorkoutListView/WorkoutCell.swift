//
//  WorkoutCell.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 19/5/24.
//

import SwiftUI

struct WorkoutCell: View {
    @State var workout: Workout
    
    var body: some View {
        HStack{
            Text(workout.name)
                .font(.title)
            Spacer()
            NavigationLink(destination: ShowWorkoutScreen(workout: $workout)){
                Text("Show")
            }
            .buttonStyle(.borderedProminent)
        }
        
        .onDisappear(){
            print("Disappear")
            print(workout)
        }
    }
}
